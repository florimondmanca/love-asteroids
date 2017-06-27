local lume = require 'lib.lume'
local Entity = require 'core.Entity'
local ParticleSystem = require 'entity.ParticleSystem'

local w, h = love.graphics.getDimensions()

local asteroidSheet = love.graphics.newImage('assets/img/asteroid4.png')
local asteroidQuads = {
    love.graphics.newQuad(0, 0, 128, 128, asteroidSheet:getDimensions()),
    love.graphics.newQuad(128, 0, 128, 128, asteroidSheet:getDimensions()),
    love.graphics.newQuad(0, 128, 128, 128, asteroidSheet:getDimensions()),
    love.graphics.newQuad(128, 128, 128, 128, asteroidSheet:getDimensions()),
}

local Asteroid = Entity:extend()
Asteroid:set{
    speed = 100,
    radius = 21,
    omega = 1,
    rotation = 0,
    dieRadius = 10,
    scorePoints = 100
}

function Asteroid:init(t)
    Entity.init(self, t)
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    assert(t.angle, 'angle required')
    self.x = t.x
    self.y = t.y
    self.speed = t.speed or Asteroid.speed
    self.radius = t.radius or Asteroid.radius
    self.dieRadius = t.dieRadius or Asteroid.dieRadius
    self.omega = t.omega or Asteroid.omega
    self.rotation = t.rotation or Asteroid.rotation
    self.quad = lume.randomchoice(asteroidQuads)
    self.vx = self.speed * math.cos(t.angle)
    self.vy = self.speed * math.sin(t.angle)
end

function Asteroid.newRandom(t)
    t = t or {}
    t.radius = lume.noise(t.radius or Asteroid.radius, .2)
    t.speed = lume.noise(t.speed or Asteroid.speed, .5)
    t.omega = lume.noise(Asteroid.omega, .5)
    t.rotation = lume.random(0, 2*math.pi)
    return Asteroid(t)
end

function Asteroid.newRandomAtBorders(t)
    t = lume.merge(t or {}, {
        x = 0, y = 0, angle = lume.random(2*math.pi)
    })
    local a = Asteroid.newRandom(t)
    local r = a.radius
    local tlerp = {
        0, (h + 2*r) / (2*w + 2*h + 8*r),
        1/2, (2*h + w + 6*r) / (2*w + 2*h + 8*r), 1
    }
    local s = lume.random()
    a.x = lume.multilerp(tlerp, {-r, -r, w + r, w + r, -r}, s)
    a.y = lume.multilerp(tlerp, {-r, h + r, h + r, -r, -r}, s)
    return a
end

function Asteroid:doesSplit()
    return self.radius/2 >= self.dieRadius
end

function Asteroid:split(damager)
    local angle = lume.angle(self.x, self.y, damager.x, damager.y)
    local left = Asteroid.newRandom{
        x = self.x, y = self.y,
        angle = angle + math.pi/2, radius = self.radius/2,
        dieRadius = self.dieRadius,
    }
    local right = Asteroid.newRandom{
        x = self.x, y = self.y,
        angle = angle - math.pi/2, radius = self.radius/2,
        dieRadius = self.dieRadius,
    }
    local ps = ParticleSystem.burst{
        shape = 'triangle',
        x = self.x, y = self.y,
        number = math.floor(self.radius/2),
        size = lume.lerp(.1, 1, self.radius/50),
        lifetime = {.1, 1},
        direction = angle + math.pi,
        spread = math.pi/2,
        spin = 5,
        speed = {50, 300},
        colors = {
            161, 160, 156, 255,
            75, 86, 96, 0
        },
    }
    if self:doesSplit() then return left, right, ps
    else return nil, nil, ps end
end

function Asteroid:update(dt)
    -- integrate rotation
    self.rotation = self.rotation + self.omega * dt
    -- integrate translation
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    -- loop through screen
    self.x = lume.loop(self.x, 0, w, self.radius)
    self.y = lume.loop(self.y, 0, h, self.radius)
end

function Asteroid:draw()
    love.graphics.setColor(255, 255, 255)
    -- -- debug circle
    -- love.graphics.setLineWidth(1)
    -- love.graphics.circle('line', self.x, self.y, self.radius, 20)
    love.graphics.push()
        local s = self.radius/64
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.rotation)
        love.graphics.scale(s, s)
        love.graphics.draw(asteroidSheet, self.quad, -1/s*self.radius, -1/s*self.radius)
    love.graphics.pop()
end

return Asteroid
