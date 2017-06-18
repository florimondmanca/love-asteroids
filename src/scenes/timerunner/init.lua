local Signal = require 'lib.signal'
local lume = require 'lib.lume'
local gamestate = require 'lib.gamestate'

return function ()
    local super = require('scenes/game')()
    super.signals = lume.merge(super.signals, {
        end_of_game = {
            function() gamestate.switch(require 'scenes.splash') end,
        }
    })
    super.updateActions = lume.concat(super.updateActions, {
        function(self)
            if self:group('widgets').objects.timeCounter.time > 10 then
                Signal.emit('end_of_game')
            end
        end
    })
    return super
end
