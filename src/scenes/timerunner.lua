local scene = require('scenes.game'):extend()

local setup = scene.setup
function scene:setup()
    setup(self)
end

return scene
