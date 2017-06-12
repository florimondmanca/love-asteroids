local lume = require 'lib.lume'

local w, h = love.graphics.getDimensions()

local asteroid = {
    radius = 15,
    speed = 100, -- px/s
}

function asteroid.new(x, y, angle, radius, speed)
    assert(x, 'x required')
    assert(y, 'y required')
    assert(angle, 'angle required')
    local self = lume.clone(asteroid)
    self.__index = asteroid
    self.x = x
    self.y = y
    self.speed = speed or self.speed
    self.radius = radius or self.radius
    self.vx = self.speed * math.cos(angle)
    self.vy = self.speed * math.sin(angle)
    return self
end

function asteroid.newRandom(x, y, angle)
    local radius = asteroid.radius * (1 + love.math.randomNormal(.2, 0))
    local speed = asteroid.speed * (1 + love.math.randomNormal(.5, 0))
    return asteroid.new(x, y, angle, radius, speed)
end

function asteroid:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    -- loop through screen
    self.x = lume.loop(self.x, 0, w, self.radius)
    self.y = lume.loop(self.y, 0, h, self.radius)
end

function asteroid:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    love.graphics.circle('line', self.x, self.y, self.radius, 20)
end

return asteroid
