-- main.lua
local gamestate = require 'lib.hump.gamestate'

require 'core.SoundManager'
require 'sounds'

math.randomseed(os.time())

function love.load()
    gamestate.registerEvents()
    gamestate.switch(require('scenes/menu'):build())
end
