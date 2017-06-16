local class = require 'lib.class'

local Pickup = class()
Pickup:set{
    radius = 5,
    lifetime = 5,
}

function Pickup:init(x, y)
    assert(x, 'x required')
    assert(y, 'y required')
    self.x = x
    self.y = y
    self.action = function() end
    self.onCollect = function() end
end

function Pickup:onCollected(object)
    self.action(object)
end

function Pickup:draw()
    love.graphics.setColor(255, 255, 0)
    love.graphics.circle('fill', self.x, self.y, self.radius)
end

return Pickup
