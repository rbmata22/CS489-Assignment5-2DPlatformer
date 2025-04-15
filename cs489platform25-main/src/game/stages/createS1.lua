local Stage = require "src.game.stages.Stage"
local BasicTileset = require "src.game.tiling.BasicTileset"
local Background = require "src.game.tiling.Background"
local Boar = require "src.game.mobs.Boar"
local Sounds = require "src.game.Sounds"

local function createS1()
    local stage = Stage(20,50,BasicTileset)
    local mapdata = require "src.game.maps.map1"
    stage:readMapData(mapdata)

    local objdata = require "src.game.maps.map1objects"
    stage:readObjectsData(objdata)

    -- Backgrounds
    local bg1 = Background("graphics/tilesets/FreeCute/BG1.png")
    local bg2 = Background("graphics/tilesets/FreeCute/BG2.png")
    local bg3 = Background("graphics/tilesets/FreeCute/BG3.png")
    
    stage:addBackground(bg1)
    stage:addBackground(bg2)
    stage:addBackground(bg3)

    -- Initial Player Pos
    stage.initialPlayerX = 1*16
    stage.initialPlayerY = 13*16 

    -- Adding mobs
    local mob1 = Boar()
    mob1:setCoord(25*16, 12*16)
    mob1:changeDirection()
    stage:addMob(mob1)

    -- music
    stage:setMusic(Sounds["music_adventure"])

    return stage
end

return createS1