import "CoreLibs/crank"

local gfx = playdate.graphics

CRANK_SPEED = 6;

SquaresPerRow = 40;
RectWidth = 400/SquaresPerRow
RectHeight = 240/SquaresPerRow
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
CellMat[1][8] = 1

local function setCellColor(x, y)
    gfx.setColor(gfx.kColorWhite)
    if CellMat[x][y] == 1 then
        gfx.setColor(gfx.kColorBlack)
    end
end

local function getLiveNeighbors(x, y)
    local xx = 0
    local yy = 0
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
                xPos = (j-1) * RectWidth
                yPos = (i-1) * RectHeight
                setCellColor(i,j)
                gfx.fillRect(xPos, yPos, RectWidth, RectHeight)
            elseif case == 'next' then
                if CellMat[i][j] == 1 then
                    -- NextFrame[i+1][j+1] = 1
                    -- print('i: ' .. i .. '  j: ' .. j)
                    print(getLiveNeighbors(i, j))
                end
            elseif case == 'set' then
                CellMat[i][j] = NextFrame[i][j]
            end
        end
    end
end



iterateMatrix('update')
function playdate.update()
    local ticks = playdate.getCrankTicks(CRANK_SPEED)
    Frames += ticks
    if ticks ~= 0 then
        gfx.clear()
        iterateMatrix('next')
        iterateMatrix('set')
        iterateMatrix('update')
    end
end

