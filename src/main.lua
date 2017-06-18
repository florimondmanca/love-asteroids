-- main.lua

local gamestate = require 'lib.gamestate'
local SceneBuilder = require 'core.SceneBuilder'

require 'core.SoundManager'
require 'sounds'

love.math.setRandomSeed(os.time())

function love.load()
    gamestate.registerEvents()
    gamestate.switch(SceneBuilder.build('scenes/game'))
end
