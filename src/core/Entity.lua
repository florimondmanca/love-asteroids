local class = require 'lib.class'
local lume = require 'lib.lume'

local Entity = class()

function Entity:init()
    self.groups = {}
end

function Entity:kill()
    for _, group in ipairs(self.groups) do
        group:remove(self)
    end
end

return Entity
