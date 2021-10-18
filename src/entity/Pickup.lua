local Entity = require 'core.Entity'

local Pickup = Entity:extend()
Pickup:set{
    radius = 5,
    lifetime = 5,
    omega = 1,
}

function Pickup:init(t)
    Entity.init(self, t)
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    self.x = t.x
    self.y = t.y
    self.time = 0
    self.action = function() end
    self.onCollect = function() end
    self.angle = love.math.random(2*math.pi)
    function self:update(dt)
        self.time = self.time + dt
        self.y = t.y + 2 * math.sin(3*math.pi*self.time)
    end
end

function Pickup:onCollected(object)
    self.action(object)
end

function Pickup:draw()
    love.graphics.setColor(0.78, 0.78, 0.39)
    love.graphics.circle('fill', self.x, self.y, self.radius, 20)
end

return Pickup
