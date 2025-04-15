local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local Tween = require "libs.tween"
local Enemy = require "src.game.mobs.Enemy"

local Snail = Class{__includes = Enemy}
function Snail:init() Enemy:init() -- superclass const.
    
end

return Snail