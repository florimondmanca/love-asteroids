-- main.lua
require 'extensions'

local gamestate = require 'lib.gamestate'

require 'core.soundmanager'
require 'sounds'

math.randomseed(os.time())

function love.load()
    gamestate.registerEvents()
    gamestate.switch(require('scenes/menu'):build())
end
