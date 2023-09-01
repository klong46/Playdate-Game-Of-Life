local gfx = playdate.graphics

-- gfx.setColor(gfx.kColorBlack)
SquaresPerRow = 20;
RectWidth = 400/SquaresPerRow
RectHeight = 240/SquaresPerRow
Done = false

-- mt = {}          -- create the matrix
-- for i=1,10 do
--   mt[i] = {}     -- create a new row
--   for j=1,10 do
--     mt[i][j] = 0
--   end
-- end

local function alternateColors(x,y)
    if (x + y) % 2 == 0 then
        gfx.setColor(gfx.kColorBlack)
    else
        gfx.setColor(gfx.kColorWhite)
    end
end


function playdate.update()
    if not Done then
        local xPos = 0
        local yPos = 0
        for i = 0, SquaresPerRow - 1, 1 do
            for j = 0, SquaresPerRow - 1, 1 do
                xPos = j * RectWidth
                yPos = i * RectHeight
                alternateColors(i,j)
                print(j)
                gfx.fillRect(xPos, yPos, RectWidth, RectHeight)
            end
        end
        Done = true
    end
    -- playdate.drawFPS(0,0)
end
