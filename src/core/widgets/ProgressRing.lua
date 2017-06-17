local class = require 'lib.class'

local ProgressRing = class()

function ProgressRing:init(t)
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    assert(t.radius, 'radius required')
    self.x = t.x
    self.y = t.y
    self.angle = t.angle or 0
    self.span = t.span or 0
    self.radius = t.radius
    self.omega = t.omega or 1
    self.color = t.color or {255, 255, 255}
    self.lineWidth = t.lineWidth or 5
end

function ProgressRing:update(dt)
    self.angle = self.angle + self.omega * dt
end

function ProgressRing:draw()
    love.graphics.setColor(unpack(self.color))
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.arc('line', 'open', self.x, self.y, self.radius, self.angle, self.angle + self.span)
end

return ProgressRing
