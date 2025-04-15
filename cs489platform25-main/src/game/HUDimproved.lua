local Class = require "libs.hump.class"
local Coin = require "src.game.objects.Coin"
local Gem = require "src.game.objects.Gem"

local hudFont = love.graphics.newFont("fonts/Abaddon Bold.ttf",16)
local imgHead = love.graphics.newImage("graphics/char/Head.png")
local imgTime = love.graphics.newImage("graphics/obj/clock/clock.png")

local HUD = Class{}
function HUD:init(player)
    self.player = player

    self.coin = Coin()
    self.coin.x = 170
    self.coin.y = 1

    self.gems = {}
    self:createCrystals(3)
end

function HUD:createCrystals(max)
    for k = 1, max do
        self.gems[k] = Gem("gray")
        self.gems[k].y = 2
        self.gems[k].x = 40+(k-1)*12
    end
end

function HUD:update(dt)
    self.coin:update(dt)

    for k = 1, #self.gems do
        if self.player.gems >= k then
            self.gems[k]:setType("blue")
        else
            self.gems[k]:setType("grey")
        end
        self.gems[k]:update(dt)
    end
end

function HUD:drawCrystals()
    for k = 1, #self.gems do
        self.gems[k]:draw()
    end
end

function HUD:drawHpBar()
    love.graphics.setColor(0.6,0,0) -- dark red
    love.graphics.rectangle("fill",91,4,self.player.hp*70/100,14) -- red bar
    love.graphics.setColor(1,1,1) -- white
    love.graphics.rectangle("line",90,4,72,14,4) -- white border
    love.graphics.printf(self.player.hp.."/100",hudFont,90,4,70,"center") -- HP text
end

function HUD:draw()
    love.graphics.draw(imgHead,5,1)
    love.graphics.print("x"..self.player.lives, hudFont, 22, 4)

    self:drawCrystals()

    self:drawHpBar()

    self.coin:draw()
    love.graphics.print("x"..self.player.coins,hudFont, 186, 4)

    love.graphics.draw(imgTime,210,1)
    love.graphics.print("x"..99, hudFont, 226,4)

    love.graphics.printf("Score:"..self.player.score,hudFont,240,4,80,"right")    
end

return HUD