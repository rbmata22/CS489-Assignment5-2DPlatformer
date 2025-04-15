local Class = require "libs.hump.class"

-- Here we create a specific font in our HUD
local hudFont = love.graphics.newFont("fonts/Abaddon Bold.ttf",16)

local HUD = Class{}
function HUD:init(player)
    self.player = player

end

function HUD:update(dt)
end

function HUD:draw()
    --love.graphics.print( text, font, x, y,
    love.graphics.print("Lives:"..self.player.lives,hudFont,5,1)
    love.graphics.print("Coins:"..self.player.coins,hudFont,55,1)
    love.graphics.print("Gems:"..self.player.gems,hudFont,115,1)
    love.graphics.print("Time:"..99,hudFont,190,1) 
    -- Time is usually Stage specific for Platformers
    love.graphics.print("Score:"..self.player.score,hudFont,250,1)

end

return HUD