local lume = require 'lib.lume'

local w, h = love.graphics.getDimensions()

local asteroid = {
    name = 'Asteroid',
    radius = 20,
    speed = 100, -- px/s
    dieRadius = 15,
}

function asteroid.new(t)
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    assert(t.angle, 'angle required')
    local self = lume.clone(asteroid)
    self.__index = asteroid
    self.x = t.x
    self.y = t.y
    self.speed = t.speed or self.speed
    self.radius = t.radius or self.radius
    self.vx = self.speed * math.cos(t.angle)
    self.vy = self.speed * math.sin(t.angle)
    return self
end

function asteroid:die()
    require('objectManager'):removeAsteroid(self)
end

function asteroid:blowup(damager)
    -- if asteroid is big enough, break it into pieces
    if self.radius > asteroid.dieRadius then
        local a = lume.angle(self.x, self.y, damager.x, damager.y)
        require('objectManager'):addAsteroid(asteroid.new{
            x = self.x, y = self.y,
            angle = a + math.pi/2, radius = self.radius/2
        })
        require('objectManager'):addAsteroid(asteroid.new{
            x = self.x, y = self.y,
            angle = a - math.pi/2, radius = self.radius/2
        })
    end
    self:die()
end

function asteroid:onMessage(m)
    if m.type == 'blowup' then
        self:blowup(m.from)
        return true
    end
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

---

function asteroid.newRandomAtBorders()
    local t = love.math.random()
    local a0 = love.math.random() * math.pi
    local a = require('asteroid').new{
        x=0, y=0,
        angle=math.pi/16 + math.floor(a0/4) * math.pi/8 + a0,
        radius=asteroid.radius * (1 + love.math.randomNormal(.2, 0)),
        speed=asteroid.speed * (1 + love.math.randomNormal(.5, 0))
    }
    local r = a.radius
    local tlerp = {
        0, (h + 2*r) / (2*w + 2*h + 8*r),
        1/2, (2*h + w + 6*r) / (2*w + 2*h + 8*r), 1
    }
    a.x = lume.multilerp(tlerp, {-r, -r, w + r, w + r, -r}, t)
    a.y = lume.multilerp(tlerp, {-r, h + r, h + r, -r, -r}, t)
    return a
end

return asteroid
