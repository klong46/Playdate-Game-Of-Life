import "CoreLibs/crank"

-- print helpers:
-- print('x: ' .. x .. '  y: ' .. y)
-- print('i: ' .. i .. '  j: ' .. j)

local gfx = playdate.graphics

CRANK_SPEED = 6;
SquarePerSide = 10;
RectWidth = 0
RectHeight = 0
Cursor = {x = 1, y = 1}
Frames = 1
CellMat = {}
NextFrame = {}

local function setCellColor(x, y)
    gfx.setColor(gfx.kColorWhite)
    if CellMat[x][y] == 1 then
        gfx.setColor(gfx.kColorBlack)
    end
end

local function getLiveNeighbors(x, y)
    local liveNeighbors = 0
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            local validX = not (x + i == 0 or x + i > SquarePerSide)
            local validY = not (y + j == 0 or y + j > SquarePerSide)
            local notSame = not (i == 0 and j == 0)
            if validX and validY and notSame then
                if CellMat[x+i][y+j] == 1 then
                    liveNeighbors += 1
                end
            end
        end
    end
    return liveNeighbors
end

local function drawCells(x, y, fullReset)
    local notCursor = not (x == Cursor.x and y == Cursor.y)
    if fullReset then
        notCursor = true
    end
    local xPos = (x - 1) * RectWidth
    local yPos = (y - 1) * RectHeight
    setCellColor(x, y)
    if notCursor then
        gfx.fillRect(xPos, yPos, RectWidth, RectHeight)
    end
end

local function iterateMatrix(case, fullReset)
    for i = 1, SquarePerSide, 1 do
        for j = 1, SquarePerSide, 1 do
            if case == 'update' then
                drawCells(i, j, fullReset)
            elseif case == 'next' then
                local liveNeighbors = getLiveNeighbors(i, j)
                if CellMat[i][j] == 1 then
                    if liveNeighbors < 2 or liveNeighbors > 3 then
                        NextFrame[i][j] = 0
                    elseif liveNeighbors == 2 or liveNeighbors == 3 then
                        NextFrame[i][j] = 1
                    end
                elseif liveNeighbors == 3 then
                    NextFrame[i][j] = 1
                end
            elseif case == 'set' then
                CellMat[i][j] = NextFrame[i][j]
            end
        end
    end
end

local function drawCursor()
    gfx.fillRect((Cursor.x-1) * RectWidth, (Cursor.y-1) * RectHeight, RectWidth, RectHeight)
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
    setCellColor(Cursor.x, Cursor.y)
    drawCursor()
end

local function moveCursor(x, y)
    deletePreviousCursor()
    Cursor.x += x
    Cursor.y += y
    setCursor()
end

function playdate.leftButtonDown()
    if Cursor.x > 1 then
        moveCursor(-1,0)
    end
end

function playdate.rightButtonDown()
    if Cursor.x < SquarePerSide then
        moveCursor(1,0)
    end
end

function playdate.upButtonDown()
    if Cursor.y > 1 then
        moveCursor(0,-1)
    end
end

function playdate.downButtonDown()
    if Cursor.y < SquarePerSide then
        moveCursor(0,1)
    end
end

function playdate.AButtonDown()
    if CellMat[Cursor.x][Cursor.y] == 0 then
        CellMat[Cursor.x][Cursor.y] = 1
    else
        CellMat[Cursor.x][Cursor.y] = 0
    end
end

local function resetGrid(size)
    SquarePerSide = size
    RectWidth = playdate.display.getWidth()/SquarePerSide
    RectHeight = playdate.display.getHeight()/SquarePerSide
    for i = 1, SquarePerSide do
        CellMat[i] = {}
        for j = 1, SquarePerSide do
            CellMat[i][j] = 0
        end
    end
    for i = 1, SquarePerSide do
        NextFrame[i] = {}
        for j = 1, SquarePerSide do
            NextFrame[i][j] = 0
        end
    end
    iterateMatrix('update', true)
    Cursor = {x = 1, y = 1}
    setCursor()
end

resetGrid(10)
setCursor()
local menu = playdate.getSystemMenu()
menu:addMenuItem("10x10", function()
    resetGrid(10)
end)
menu:addMenuItem("20x20", function()
    resetGrid(20)
end)
menu:addMenuItem("40x40", function()
    resetGrid(40)
end)
function playdate.update()
    local ticks = playdate.getCrankTicks(CRANK_SPEED)
    Frames += ticks
    if ticks > 0 then
        iterateMatrix('next')
        iterateMatrix('set')
        iterateMatrix('update', false)
    end
end

