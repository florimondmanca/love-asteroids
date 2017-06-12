local lume = require 'lib.lume'

local manager = {objects = {}}

function manager:add(o)
    lume.push(self.objects, o)
end

function manager:set(key, o)
    self.objects[key] = o
end

function manager:remove(o)
    lume.remove(self.objects, o)
end

return manager
