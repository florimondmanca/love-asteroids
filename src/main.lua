-- main.lua

local GameState = require 'lib.gamestate'

require 'core.SoundManager'

love.math.setRandomSeed(os.time())

function love.load()
    GameState.registerEvents()
    GameState.switch(require 'scenes.splash')
end
