local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local GameObject = require "src.game.objects.GameObject"

local spriteGold = love.graphics.newImage(
    "graphics/obj/coins/gold.png")
local spriteSilver = love.graphics.newImage(
    "graphics/obj/coins/silver.png")
local spriteRed = love.graphics.newImage(
    "graphics/obj/coins/red.png")

local gridCoin = Anim8.newGrid(16,16,
    spriteGold:getWidth(),spriteGold:getHeight())
local animCoin = Anim8.newAnimation(gridCoin("1-5",1) ,0.1)

local Coin = Class{__includes = GameObject}
function Coin:init(type) GameObject:init()
    self.name = "coin"
    self.type = type 
    self.sprite = spriteGold
    self.animation = animCoin:clone()

    self:setType(type)
end

function Coin:setType(type)
    if type == "silver" then
        self.type = "silver"
        self.sprite = spriteSilver
    elseif type == "red" then
        self.type = "red"
        self.sprite = spriteRed
    else
        self.type = "gold"
        self.sprite = spriteGold
    end
end

function Coin:setRandomType()
    -- To Do
end

return Coin