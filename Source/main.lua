import "CoreLibs/crank"

local gfx = playdate.graphics

CRANK_SPEED = 6;

SQUARES_PER_SIDE = 20;
RectWidth = 400/SQUARES_PER_SIDE
RectHeight = 240/SQUARES_PER_SIDE
Cursor = {x = 12, y = 12}
Frames = 1

CellMat = {}
for i=1,SQUARES_PER_SIDE do
    CellMat[i] = {}
  for j=1,SQUARES_PER_SIDE do
    CellMat[i][j] = 0
  end
end

NextFrame = {}
for i=1,SQUARES_PER_SIDE do
    NextFrame[i] = {}
  for j=1,SQUARES_PER_SIDE do
    NextFrame[i][j] = 0
  end
end

CellMat[1][1] = 1
CellMat[1][2] = 1
CellMat[2][1] = 1
CellMat[1][8] = 1

CellMat[10][10] = 1
CellMat[11][10] = 1
CellMat[12][10] = 1
CellMat[16][16] = 1

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
            local validX = not (x + i == 0 or x + i > SQUARES_PER_SIDE)
            local validY = not (y + j == 0 or y + j > SQUARES_PER_SIDE)
            local notSame = not (i == 0 and j == 0)
            if validX and validY and notSame then
                if CellMat[x+i][y+j] == 1 then
                    -- print('x: ' .. x .. '  y: ' .. y)
                    -- print('i: ' .. i .. '  j: ' .. j)
                    liveNeighbors += 1
                end
            end
        end
    end
    return liveNeighbors
end

local function iterateMatrix(case)
    local xPos = 0
    local yPos = 0
    for i = 1, SQUARES_PER_SIDE, 1 do
        for j = 1, SQUARES_PER_SIDE, 1 do
            if case == 'update' then
                local notCursor = not (i == Cursor.x and j == Cursor.y)
                xPos = (i-1) * RectWidth
                yPos = (j-1) * RectHeight
                setCellColor(i,j)
                if notCursor then
                    -- print('i: ' .. i .. '  j: ' .. j)
                    gfx.fillRect(xPos, yPos, RectWidth, RectHeight)
                end
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
    if Cursor.x < SQUARES_PER_SIDE then
        moveCursor(1,0)
    end
end

function playdate.upButtonDown()
    if Cursor.y > 1 then
        moveCursor(0,-1)
    end
end

function playdate.downButtonDown()
    if Cursor.y < SQUARES_PER_SIDE then
        moveCursor(0,1)
    end
end

function playdate.AButtonDown()
    CellMat[Cursor.x][Cursor.y] = 1
end

iterateMatrix('update')
setCursor()
function playdate.update()
    local ticks = playdate.getCrankTicks(CRANK_SPEED)
    Frames += ticks
    if ticks ~= 0 then
        iterateMatrix('next')
        iterateMatrix('set')
        iterateMatrix('update')
    end
end

