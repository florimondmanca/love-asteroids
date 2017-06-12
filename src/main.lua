-- main.lua

require 'core.soundManager'
love.audio.play('assets/audio/ost.wav', 'stream', true)

-- initial config
love.math.setRandomSeed(os.time())
love.graphics.setBackgroundColor(40, 45, 55)

-- load object manager
local objectManager = require 'entity.objectManager'

-- define love2d callbacks
for _, fname in ipairs({
    'update', 'draw', 'mousepressed', 'mousereleased',
    'keypressed', 'keyreleased',
}) do
    love[fname] = function(...)
        objectManager[fname](objectManager, ...)
    end
end
