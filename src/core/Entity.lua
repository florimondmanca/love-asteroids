local class = require 'lib.class'
-- local lume = require 'lib.lume'

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

-- TODO update for moonshine support
-- function Entity:fxOn()
--     require('core.fxSupport').forObject(self)
-- end

return Entity
