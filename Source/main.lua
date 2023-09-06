import "CoreLibs/crank"
import "CoreLibs/timer"

local gfx = playdate.graphics
local CRANK_SPEED = 6;
local INIT_MOVE_DELAY = 200
local MOVE_DELAY = 50
local cellsPerSide = 10;
local cellWidth = 0
local cellHeight = 0
local cursorPos = {x = 1, y = 1}
local cellGrid = {}
local nextCellGrid = {}
local moveLeftTimer = nil
local moveRightTimer = nil
local moveUpTimer = nil
local moveDownTimer = nil


local function setCellColor(x, y)
    gfx.setColor(gfx.kColorWhite)
    if cellGrid[x][y] == 1 then
        gfx.setColor(gfx.kColorBlack)
    end
end

local function getLiveNeighbors(x, y)
    local liveNeighbors = 0
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            local validX = not (x + i == 0 or x + i > cellsPerSide)
            local validY = not (y + j == 0 or y + j > cellsPerSide)
            local notSame = not (i == 0 and j == 0)
            if validX and validY and notSame then
                if cellGrid[x+i][y+j] == 1 then
                    liveNeighbors += 1
                end
            end
        end
    end
    return liveNeighbors
end

local function drawCells(x, y, fullReset)
    local notCursor = not (x == cursorPos.x and y == cursorPos.y)
    if fullReset then
        notCursor = true
    end
    local xPos = (x - 1) * cellWidth
    local yPos = (y - 1) * cellHeight
    setCellColor(x, y)
    if notCursor then
        gfx.fillRect(xPos, yPos, cellWidth, cellHeight)
    end
end

local function iterateMatrix(case, fullReset)
    for i = 1, cellsPerSide, 1 do
        for j = 1, cellsPerSide, 1 do
            if case == 'update' then
                drawCells(i, j, fullReset)
            elseif case == 'next' then
                local liveNeighbors = getLiveNeighbors(i, j)
                if cellGrid[i][j] == 1 then
                    if liveNeighbors < 2 or liveNeighbors > 3 then
                        nextCellGrid[i][j] = 0
                    elseif liveNeighbors == 2 or liveNeighbors == 3 then
                        nextCellGrid[i][j] = 1
                    end
                elseif liveNeighbors == 3 then
                    nextCellGrid[i][j] = 1
                end
            elseif case == 'set' then
                cellGrid[i][j] = nextCellGrid[i][j]
            end
        end
    end
end

local function drawCursor()
    gfx.fillRect((cursorPos.x-1) * cellWidth, (cursorPos.y-1) * cellHeight, cellWidth, cellHeight)
end

local function getCheckerboard()
    local checkerboard = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 }
    gfx.setPattern(checkerboard)
end

local function setCursor()
    getCheckerboard()
    drawCursor()
end

local function deletePreviousCursor()
    setCellColor(cursorPos.x, cursorPos.y)
    drawCursor()
end

local function moveCursor(x, y)
    deletePreviousCursor()
    cursorPos.x += x
    cursorPos.y += y
    setCursor()
end

local function changeCellColor()
    if cellGrid[cursorPos.x][cursorPos.y] == 0 then
        cellGrid[cursorPos.x][cursorPos.y] = 1
    else
        cellGrid[cursorPos.x][cursorPos.y] = 0
    end
end

local function changeContinuousCells()
    if playdate.buttonIsPressed(playdate.kButtonA) then
        changeCellColor()
    end
end

local function moveCursorLeft()
    if cursorPos.x > 1 then
        moveCursor(-1,0)
        changeContinuousCells()
    end
end

local function moveCursorRight()
    if cursorPos.x < cellsPerSide then
        moveCursor(1,0)
        changeContinuousCells()
    end
end

local function moveCursorUp()
    if cursorPos.y > 1 then
        moveCursor(0,-1)
        changeContinuousCells()
    end
end

local function moveCursorDown()
    if cursorPos.y < cellsPerSide then
        moveCursor(0,1)
        changeContinuousCells()
    end
end

function playdate.rightButtonDown()
    moveRightTimer = playdate.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveCursorRight)
end

function playdate.upButtonDown()
    moveUpTimer = playdate.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveCursorUp)
end

function playdate.downButtonDown()
    moveDownTimer = playdate.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveCursorDown)
end

function playdate.leftButtonDown()
    moveLeftTimer = playdate.timer.keyRepeatTimerWithDelay(INIT_MOVE_DELAY, MOVE_DELAY, moveCursorLeft)
end

function playdate.leftButtonUp()
    moveLeftTimer:remove()
end

function playdate.rightButtonUp()
    moveRightTimer:remove()
end

function playdate.upButtonUp()
    moveUpTimer:remove()
end

function playdate.downButtonUp()
    moveDownTimer:remove()
end

function playdate.AButtonDown()
    changeCellColor()
end

local function resetGrid(size)
    cellsPerSide = size
    cellWidth = playdate.display.getWidth()/cellsPerSide
    cellHeight = playdate.display.getHeight()/cellsPerSide
    for i = 1, cellsPerSide do
        cellGrid[i] = {}
        for j = 1, cellsPerSide do
            cellGrid[i][j] = 0
        end
    end
    for i = 1, cellsPerSide do
        nextCellGrid[i] = {}
        for j = 1, cellsPerSide do
            nextCellGrid[i][j] = 0
        end
    end
    iterateMatrix('update', true)
    cursorPos = {x = 1, y = 1}
    setCursor()
end

resetGrid(10)
setCursor()
local menu = playdate.getSystemMenu()
menu:addMenuItem("40x40", function()
    resetGrid(40)
end)
menu:addMenuItem("20x20", function()
    resetGrid(20)
end)
menu:addMenuItem("10x10", function()
    resetGrid(10)
end)

function playdate.update()
    playdate.timer.updateTimers()
    local ticks = playdate.getCrankTicks(CRANK_SPEED)
    if ticks > 0 then
        iterateMatrix('next')
        iterateMatrix('set')
        iterateMatrix('update', false)
    end
end

