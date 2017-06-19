local class = require 'lib.class'
local lume = require 'lib.lume'

local Entity = class()

function Entity:init()
    self.groups = {}
    self.effects = {}
end

function Entity:addEffect(fx, name)
    if name then self.effects[name] = fx end
    lume.push(self.effects, fx)
end

function Entity:fxOn(func)
    local fx
    if #self.effects > 0 then
        fx = lume.reduce(self.effects, function(a, b) return a:chain(b) end)
    else fx = function(f) f() end end
    fx(func)
end

function Entity:kill()
    for _, group in ipairs(self.groups) do
        group:remove(self)
    end
end

return Entity
