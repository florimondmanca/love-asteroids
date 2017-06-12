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

function manager.group()
    local group = lume.clone(manager)
    group.objects = {}

    for _, fname in ipairs{'update', 'draw', 'mousepressed', 'mousereleased',
    'keypressed', 'keyreleased'} do
        group[fname] = function(self, ...)
            for _, o in pairs(group.objects) do
                if o[fname] then o[fname](o, ...) end
            end
        end
    end

    return group
end

return manager
