local gfx = playdate.graphics

-- gfx.setColor(gfx.kColorBlack)
SquaresPerRow = 14;
RectWidth = 400/SquaresPerRow
RectHeight = 240/SquaresPerRow
Done = false

CellMat = {}          -- create the matrix
for i=1,SquaresPerRow do
    CellMat[i] = {}     -- create a new row
  for j=1,SquaresPerRow do
    CellMat[i][j] = 0
  end
end

CellMat[10][10] = 1
CellMat[1][8] = 1

-- local function alternateColors(x,y)
--     gfx.setColor(gfx.kColorWhite)
--     if (x + y) % 2 == 0 then
--         gfx.setColor(gfx.kColorBlack)
--     end
-- end

local function setCellColor(x, y)
    gfx.setColor(gfx.kColorWhite)
    if CellMat[x][y] == 1 then
        gfx.setColor(gfx.kColorBlack)
    end
end


function playdate.update()
    if not Done then
        local xPos = 0
        local yPos = 0
        for i = 1, SquaresPerRow, 1 do
            for j = 1, SquaresPerRow, 1 do
                xPos = (j-1) * RectWidth
                yPos = (i-1) * RectHeight
                -- alternateColors(i,j)
                setCellColor(i,j)
                gfx.fillRect(xPos, yPos, RectWidth, RectHeight)
            end
        end
        Done = true
    end
    -- playdate.drawFPS(0,0)
end
