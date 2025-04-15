local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local Timer = require "libs.hump.timer"
local Enemy = require "src.game.mobs.Enemy"
local Hbox = require "src.game.Hbox"
local Sounds = require "src.game.Sounds"
local Tween = require "libs.tween"

-- Idle Animation Resources
local idleSprite = love.graphics.newImage("graphics/mobs/boar/Idle-Sheet.png")
local idleGrid = Anim8.newGrid(48, 32, idleSprite:getWidth(), idleSprite:getHeight())
local idleAnim = Anim8.newAnimation(idleGrid('1-4',1),0.2)
-- Walk Animation Resources
local walkSprite = love.graphics.newImage("graphics/mobs/boar/Walk-Sheet.png")
local walkGrid = Anim8.newGrid(48, 32, walkSprite:getWidth(), walkSprite:getHeight())
local walkAnim = Anim8.newAnimation(walkGrid('1-6',1),0.2)
-- Hit Animation Resources
local hitSprite = love.graphics.newImage("graphics/mobs/boar/Hit-Sheet.png")
local hitGrid = Anim8.newGrid(48, 32, hitSprite:getWidth(), hitSprite:getHeight())
local hitAnim = Anim8.newAnimation(hitGrid('1-4',1),0.2)


local Boar = Class{__includes = Enemy}
function Boar:init(type) Enemy:init() -- superclass const.
    self.name = "boar"
    self.type = type
    if type == nil then self.type = "brown" end

    self.dir = "l" -- Direction r = right, l = left
    self.state = "idle" -- idle state
    self.animations = {} -- dict of animations (each mob will have its own)
    self.sprites = {} -- dict of sprites (for animations)
    self.hitboxes = {}
    self.hurtboxes = {}
    self.particleStage = nil -- placeholder for when stage is created and an explosion is registered

    self.hp = 20
    self.score = 200
    self.damage = 20

    self:setAnimation("idle",idleSprite, idleAnim)
    self:setAnimation("walk",walkSprite, walkAnim)
    self:setAnimation("hit", hitSprite, hitAnim)

    self:setHurtbox("idle",10,10,34,22)
    self:setHurtbox("walk",10,10,34,22)
    self:setHurtbox("hit",6,2,34,30)

    self:setHitbox("idle",10,10,34,22)
    self:setHitbox("walk",10,10,34,22)
    --self:setHurtbox("hit",6,2,34,30)


    Timer.every(5,function() self:changeState() end)
end

function Boar:changeState()
    if self.state == "idle" then
            self.state = "walk"
    elseif self.state == "walk" then
        self.state = "idle"
    end
end
    

function Boar:update(dt, stage)
    self.particleStage = stage -- stage is now initialized

    if self.state == "walk" then
        if not stage:bottomCollision(self,1,0) then -- not on solid ground
            self.y = self.y + 32*dt -- fall 
        elseif self.dir == "l" then -- on ground and walking left
            if stage:leftCollision(self,0) then -- collision, change dir
                self:changeDirection()
            else -- no collision, keep walking left
                self.x = self.x-16*dt
            end
        else -- on ground and walking right
            if stage:rightCollision(self,0) then -- collision, change dir
                self:changeDirection()
            else -- no collision, keep walking right
                self.x = self.x+16*dt
            end 
        end -- end if bottom collision & dir 
    end -- end if walking state
    Timer.update(dt) -- attention, Timer.update uses dot, and not :
    self.animations[self.state]:update(dt)
    Enemy.update(self, dt) -- uses Enemy class to handle tween animation
end -- end function
    
function Boar:hit(damage, direction)
    if self.invincible then return end

    self.invincible = true
    self.hp = self.hp - damage
    self.state = "hit"
    Sounds["mob_hurt"]:play()

    self:takingDamage() -- displaying damage and tween animation

    if self.hp <= 0 then
        Timer.after(1, function() 
            self.died = true
            local width,height = self:getDimensions() -- gets current position of boar
            if self.particleStage then
                self.particleStage:createExplosion(self.x+width/2, self.y+height/2) -- tells stage to make an explosion where the boar is located
            end
        end) -- gives a slight pause before death for damage text to stay displayed for longer
    end

    Timer.after(1, function() self:endHit(direction) end)
    Timer.after(0.9, function() self.invincible = false end)

end

function Boar:endHit(direction)
    if self.dir == direction then
        self:changeDirection()
    end
    self.state = "walk"
end

return Boar