-- Sound Dictionary / Table
local sounds = {}  -- create an empty table

sounds["music_adventure"] = love.audio.newSource("sounds/timbeek/8Bit_Adventure.wav","static")
sounds["music_adventure"]:setVolume(0.3)
sounds["music_surfrock"] = love.audio.newSource("sounds/timbeek/Surf_Rock_Light.wav","static")
sounds["music_surfrock"]:setVolume(0.3)
-- Add this to the file
sounds["attack1"] = love.audio.newSource("sounds/leohpaz/Slash.wav","static")
sounds["attack2"] = love.audio.newSource("sounds/leohpaz/Claw.wav","static")
sounds["mob_hurt"] = love.audio.newSource("sounds/kronbits/Impact_Punch.wav","static")
sounds["player_hurt"] = love.audio.newSource("sounds/kronbits/Punch_Hurt.wav","static")
sounds["coin"] = love.audio.newSource("sounds/bfxr/Pickup_Coin.wav","static")
sounds["gem"] = love.audio.newSource("sounds/kronbits/Blop.wav","static")
sounds["jump"] = love.audio.newSource("sounds/kronbits/Jump_Classic.wav","static")
sounds["die"] = love.audio.newSource("sounds/kronbits/Negative_Short.wav","static")
sounds["game_over"] = love.audio.newSource("sounds/kronbits/Negative_Melody.wav","static")
sounds["level_completed"] = love.audio.newSource("sounds/kronbits/Success_Melody.wav","static")

return sounds
