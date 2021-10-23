local class = require 'utils.class'

local Entity = class()

function Entity:init(t)
    t = t or {}
    self.groups = {}
    self.z = t.z or 0  -- layer
end

function Entity:kill()
    for _, group in ipairs(self.groups) do
        group:remove(self)
    end
end

return Entity
