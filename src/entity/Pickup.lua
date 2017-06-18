local class = require 'lib.class'

local Pickup = class()
Pickup:set{
    radius = 5,
    lifetime = 5,
    omega = 1,
}

function Pickup:init(x, y)
    assert(x, 'x required')
    assert(y, 'y required')
    self.x = x
    self.y = y
    self.time = 0
    self.action = function() end
    self.onCollect = function() end
    self.angle = love.math.random(2*math.pi)
    function self:update(dt)
        self.time = self.time + dt
        self.y = y + 2 * math.sin(3*math.pi*self.time)
    end
end

function Pickup:onCollected(object)
    self.action(object)
end

function Pickup:draw()
    love.graphics.setColor(200, 200, 100)
    love.graphics.circle('fill', self.x, self.y, self.radius, 20)
end

return Pickup
