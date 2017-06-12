local lume = require 'lib.lume'

local shot = {
    radius = 5,
    speed = 250, -- px/s
    lifetime = 1, -- seconds
    time = 0,
}

function shot.new(x, y, angle)
    assert(x, 'x required')
    assert(y, 'y required')
    assert(angle, 'angle required')
    local self = lume.clone(shot)
    self.__index = shot
    self.x = x
    self.y = y
    self.vx = self.speed * math.cos(angle)
    self.vy = self.speed * math.sin(angle)
    return self
end

function shot:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.time = self.time + dt
    if self.time > self.lifetime then
        require('objectManager'):remove(self)
    end
end

function shot:draw()
    love.graphics.setColor(255, 255, 255, lume.lerp(255, 0, (self.time/self.lifetime)^10))
    love.graphics.circle('fill', self.x, self.y, self.radius, 20)
end

return shot
