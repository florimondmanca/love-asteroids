-- main.lua

local gamestate = require 'lib.gamestate'

require 'core.SoundManager'
require 'sounds'

love.math.setRandomSeed(os.time())

function love.load()
    gamestate.registerEvents()
    gamestate.switch(require 'scenes.game')
end
