local Signal = require 'lib.hump.signal'
local gamestate = require 'lib.hump.gamestate'

local S = require('scenes/game')

S:addSignalListener('end_of_game', function()
    gamestate.switch(require('scenes/splash'):build())
end)

S:addUpdateAction(function(self)
    -- check timecounter
    if self:group('widgets').objects.timeCounter.time >= 10 then
        Signal.emit('end_of_game')
    end
end)

return S
