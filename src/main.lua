-- main.lua

local GameState = require 'lib.gamestate'
local Timer = require 'core.Timer'

require 'core.SoundManager'

love.math.setRandomSeed(os.time())

function love.load()
    GameState.registerEvents()
    GameState.switch(require 'scenes.splash')
    Timer:after(5, function() GameState.switch(require 'scenes.game') end)
end
