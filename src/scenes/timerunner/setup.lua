local Signal = require 'lib.signal'
local lume = require 'lib.lume'
local gamestate = require 'lib.gamestate'

return function ()
    local super = require('scenes/game/setup')()
    super.signals = lume.merge(super.signals, {
        end_of_game = {
            function() gamestate.switch(require 'scenes.splash') end,
        }
    })
    super.updateActions = lume.merge(super.updateActions, {
        function(self)
            if self.groups.widgets.objects.timeCounter.time > 60*2 then
                Signal.emit('end_of_game')
            end
        end
    })
    return super
end
