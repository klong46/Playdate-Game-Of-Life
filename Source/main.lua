import "CoreLibs/crank"

local gfx = playdate.graphics

CRANK_SPEED = 6;

SquaresPerRow = 40;
RectWidth = 400/SquaresPerRow
RectHeight = 240/SquaresPerRow
PickerPos = {x = 15, y = 15}
Frames = 1
Done = false

CellMat = {}
for i=1,SquaresPerRow do
    CellMat[i] = {}
  for j=1,SquaresPerRow do
    CellMat[i][j] = 0
  end
end

NextFrame = {}
for i=1,SquaresPerRow do
    NextFrame[i] = {}
  for j=1,SquaresPerRow do
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
            local validX = not (x + i == 0 or x + i > SquaresPerRow)
            local validY = not (y + j == 0 or y + j > SquaresPerRow)
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
    for i = 1, SquaresPerRow, 1 do
        for j = 1, SquaresPerRow, 1 do
            if case == 'update' then
                local notPickerPos = not (i == PickerPos.x and j == PickerPos.y)
                xPos = (j-1) * RectWidth
                yPos = (i-1) * RectHeight
                setCellColor(i,j)
                if notPickerPos then
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

local function createCursor()
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)
    gfx.drawRect((PickerPos.x-1) * RectWidth, (PickerPos.y-1) * RectHeight, RectWidth, RectHeight)
end


iterateMatrix('update')
createCursor()
function playdate.update()
    local ticks = playdate.getCrankTicks(CRANK_SPEED)
    Frames += ticks
    if ticks ~= 0 then
        -- gfx.clear()
        -- createPicker()
        iterateMatrix('next')
        iterateMatrix('set')
        iterateMatrix('update')
    end
end

