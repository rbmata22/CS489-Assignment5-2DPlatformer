local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local Tween = require "libs.tween"
local Hbox = require "src.game.Hbox"
local Sounds = require "src.game.Sounds"

local idleSprite = love.graphics.newImage(
    "graphics/char/Idle-Sheet.png")
local idleGrid = Anim8.newGrid(64,80,
    idleSprite:getWidth(),idleSprite:getHeight())
local idleAnim = Anim8.newAnimation( idleGrid('1-4',1), 0.3)

local runSprite = love.graphics.newImage(
    "graphics/char/Run-Sheet.png")
local runGrid = Anim8.newGrid(80,80,
    runSprite:getWidth(),runSprite:getHeight())
local runAnim = Anim8.newAnimation( runGrid('1-8',1), 0.1)

local jumpSprite = love.graphics.newImage(
    "graphics/char/Jump-All-Sheet.png")
local jumpGrid = Anim8.newGrid(64,64,
    jumpSprite:getWidth(),jumpSprite:getHeight())
local jumpAnim = Anim8.newAnimation( jumpGrid('1-15',1), 0.1)

-- Attack Animation Resources
local attackSprite = love.graphics.newImage("graphics/char/Attack-Sheet.png")
local attackGrid = Anim8.newGrid(96, 80, attackSprite:getWidth(), attackSprite:getHeight())
local attack1Anim = Anim8.newAnimation(attackGrid('1-4',1),0.15)
local attack2Anim = Anim8.newAnimation(attackGrid('5-8',1),0.15)

-- Getting Hit Animation Resources (reusing Jump Sprites)
local hitSprite = jumpSprite
local hitGrid = jumpGrid
local hitAnim = Anim8.newAnimation(hitGrid('13-14',1,2,1),0.3)
-- Gets the frames 13-14, line 1, and frame 2, line 1

-- Dying animation resources
local dieSprite = love.graphics.newImage("graphics/char/Dead-Sheet.png")
local dieGrid = Anim8.newGrid(80, 80, dieSprite:getWidth(), dieSprite:getHeight())
local dieAnim = Anim8.newAnimation(dieGrid('1-8',1),0.1)

local Player = Class{}
function Player:init(x,y)
    self.x = x
    self.y = y
    self.name = "char"
    self.hitboxes = {}
    self.hurtboxes = {}

    self.state = "idle"
    self.dir = "r" -- r for right, l for left
    self.speedY = 0

    self.animations = {}
    self.sprites = {}
    self:createAnimations()

    self.lives = 3
    self.hp = 100
    self.coins = 0
    self.gems = 0
    self.score = 0
end

function Player:nextStage(stage)
    self.x = stage.initialPlayerX
    self.y = stage.initialPlayerY
    
    self.crystals = 0 
    self.hp = math.min(100, self.hp+10)
end

function Player:reset()
    self:setDirection("r") -- Direction r = right, l = left
    self.state = "idle" -- idle state
    self.lives = 3
    self.hp = 100 -- hit/health points for later
    self.coins = 0 -- coins collected
    self.crystals = 0 -- crystals found
    self.score = 0 -- score so far 
end

function Player:createAnimations() -- fill up the animations & sprites
    self.animations["idle"] = idleAnim
    self.sprites["idle"] = idleSprite

    self.animations["run"] = runAnim
    self.sprites["run"] = runSprite

    self.animations["jump"] = jumpAnim
    self.sprites["jump"] = jumpSprite

    -- Add this to Player:createAnimations()
    self.animations["attack1"] = attack1Anim
    self.animations["attack1"].onLoop = function() self:finishAttack() end
    self.sprites["attack1"] = attackSprite

    self.animations["attack2"] = attack2Anim
    self.animations["attack2"].onLoop = function() self:finishAttack() end
    self.sprites["attack2"] = attackSprite

    self.animations["hit"] = hitAnim
    self.animations["hit"].onLoop = function() self:finishHit() end
    self.sprites["hit"] = hitSprite

    self.animations["die"] = dieAnim
    self.animations["die"].onLoop = function() self:died() end
    self.sprites["die"] = dieSprite

    -- Add these to Player:createAnimations()
    self.hurtboxes["idle"] = Hbox(self,24,16,16,48)
    self.hurtboxes["run"] = Hbox(self,34,16,26,48)
    self.hurtboxes["attack1"] = Hbox(self,34,16,26,48)
    self.hitboxes["attack1"] = Hbox(self,60,0,34,64)
    self.hurtboxes["attack2"] = Hbox(self,34,16,26,48)
    self.hitboxes["attack2"] = Hbox(self,60,16,34,64)
    self.hurtboxes["jump"] = Hbox(self,12,10,26,48)


end

function Player:update(dt, stage)
    -- movement logic first
    if love.keyboard.isDown("d","right") then
        self:setDirection("r")
        if not stage:rightCollision(self, 1) then
            self.x = self.x + 96*dt
        end
    elseif love.keyboard.isDown("a","left") then
        self:setDirection("l")
        if not stage:leftCollision(self,1) then
            self.x = self.x - 96*dt
        end
    end

    -- changing states logic
    if self.state == "idle" or self.state == "run" then
        if not stage:bottomCollision(self,0,1) then
            self.state = "jump"
            self.speedY = 32
            self:jump(dt, stage)
        elseif love.keyboard.isDown("a","d","right","left") then
            self.state = "run"
        else
            self.state = "idle"
        end
    elseif self.state == "jump" then
        if self.speedY < 0 then
            self:jump(dt, stage)
        elseif not stage:bottomCollision(self,1,1) then
            self:jump(dt, stage)
        else
            self.state = "idle"
            self.speedY = 1
        end
    end

    -- collisions logic
    local obj = stage:checkObjectsCollision(self)
    if obj then
        -- Player colided with obj
        self:handleObjectCollision(obj)
    end

    if self.state == "attack1" or self.state == "attack2" then
        local mob = stage:checkMobsHboxCollision(self:getHitbox())
        if mob ~= nil then
            mob:hit(10, self.dir)
            if mob.died then 
                self.score = self.score + mob.score 
            end
        end
    end

    -- getting hit code
    if self.state ~= "hit" then -- has not been hit yet, check for it
        local mob = stage:checkMobsHboxCollision(self:getHurtbox(),"hit")
        if mob then
            self.state = "hit"
            self.speedY = -32 
            self.hp = math.max(0, self.hp - mob.damage)
        end
    else -- Player got hit, continue the animation/movement of getting hit
        if self.dir == "r" then
            self.x = math.max(0,self.x - 96*dt) -- move backwards
        else
            self.x = math.min(self.x + 96*dt, stage:getWidth()-32)
        end
        if not stage:bottomCollision(self,1,1) then --did not land on ground
            self:jump(dt, stage) -- keeps jumping/falling 
        end
    end

    -- Check Player HP for d*
    if self.hp <= 0 then 
        self.state = "die"
        Sounds["die"]:play()
    end

    -- checks if player has collected all 3 gems in the stage
    if self.gems == 3 and gameState == "play" then
        gameState = "allGemsCollected" -- changes game state to indicate a stage has been completed
    end

    self.animations[self.state]:update(dt)
end

function Player:handleObjectCollision(obj)
    if obj.name == "coin" then
        self.coins = self.coins +1
        self.score = self.score +10
        Sounds["coin"]:play()
    elseif obj.name == "gem" then
        self.gems = self.gems +1
        self.score = self.score +50
        Sounds["gem"]:play()
    end
end

function Player:draw()
    self.animations[self.state]:draw(self.sprites[self.state],
        math.floor(self.x), math.floor(self.y) )

    if debugFlag then
        local w,h = self:getDimensions()
        love.graphics.rectangle("line",self.x,self.y,w,h) -- sprite

        if self:getHurtbox() then
            love.graphics.setColor(0,0,1) -- blue
            self:getHurtbox():draw()
        end

        if self:getHitbox() then
            love.graphics.setColor(1,0,0) -- red
            self:getHitbox():draw()
        end
        love.graphics.setColor(1,1,1) 
    end
end

function Player:keypressed(key)
    if key == "space" and self.state ~= "jump" then
        self.state = "jump"
        self.speedY = -64 -- jumping speed
        self.y = self.y -1
        self.animations["jump"]:gotoFrame(1)
        Sounds["jump"]:play()
    elseif key=="f" and self.state ~="jump" 
            and self.state~="attack1" and self.state~="attack2" then
        self.state = "attack1"
        self.animations["attack1"]:gotoFrame(1)
        Sounds["attack1"]:play()
    elseif key=="f" and self.state == "attack1" then
        self.state = "attack2"
        self.animations["attack2"]:gotoFrame(1)
        Sounds["attack2"]:play()
    end
end

function Player:keyreleased(key)
    
end

function Player:setCoords(x,y)
    self.x = x
    self.y = y
end

function Player:setDirection(newdir)
    if self.dir ~= newdir then
        self.dir = newdir
        for states,anim in pairs(self.animations) do
            anim:flipH()
        end -- end for
    end -- end if
end

function Player:jump(dt, stage)
    if self.y < stage:getHeight() then
        self.y = self.y + self.speedY*dt
        self.speedY = self.speedY +64*dt -- gravity
    else -- fell to its d**
        self:died(stage)
    end
end

function Player:onGround() 
    --Deprecated, use Stage:bottomCollision instead
    --only works for stage 0
    if self.y >= 8*16 then 
        self.y = 8*16
        return true
    end
    return false
end

function Player:getDimensions()
    return self.animations[self.state]:getDimensions()
end

function Player:finishAttack()
    self.state = "idle"
end

function Player:getHbox(boxtype)
    if boxtype == "hit" then
        return self.hitboxes[self.state]
    else
        return self.hurtboxes[self.state]
    end
end

function Player:getHitbox()
    return self:getHbox("hit")
end

function Player:getHurtbox()
    return self:getHbox("hurt")
end

function Player:died(stage)
    if stage == nil then stage = stagemanager:currentStage() end

    self.lives = self.lives - 1
    self:setDirection("r")
    self.state = "idle"
    self.speedY = 1
    self.hp = 100
    self.x = stage.initialPlayerX
    self.y = stage.initialPlayerY
    Sounds["die"]:play()
end

function Player:finishHit()
    self.state = "idle"
end

return Player