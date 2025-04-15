local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local GameObject = require "src.game.objects.GameObject"

local spriteBlue = love.graphics.newImage(
    "graphics/obj/gems/blue.png")
local spriteGrey = love.graphics.newImage(
    "graphics/obj/gems/grey.png")
    
local gridGem = Anim8.newGrid(16,16,
    spriteBlue:getWidth(),spriteBlue:getHeight())
local animGem = Anim8.newAnimation(gridGem("1-4",1) ,0.2)

local Gem = Class{__includes = GameObject}
function Gem:init(type) GameObject:init()
    self.name = "gem"
    self.type = type 
    self.sprite = spriteBlue
    self.animation = animGem:clone()

    self:setType(type)
end

function Gem:setType(type)
    if type == "gray" or type == "grey" then
        self.type = "grey"
        self.sprite = spriteGrey
    else
        self.type = "blue"
        self.sprite = spriteBlue
    end
end

return Gem