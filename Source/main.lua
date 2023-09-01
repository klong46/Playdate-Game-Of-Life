local gfx = playdate.graphics

gfx.setColor(gfx.kColorBlack)


function playdate.update()
    for i = 1, 10, 1 do
        gfx.setColor(gfx.kColorBlack)
        if i % 2 == 0 then
            gfx.setColor(gfx.kColorWhite)
        end
        gfx.fillRect(20*i, 0, 20, 20)
    end
    -- playdate.drawFPS(0,0)
end
