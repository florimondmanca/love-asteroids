local lume = require 'lib.lume'
local Entity = require 'core.Entity'

local w, h = love.graphics.getDimensions()

local asteroidSheet = love.graphics.newImage('assets/img/asteroid4.png')
local asteroidQuads = {
    love.graphics.newQuad(0, 0, 128, 128, asteroidSheet:getDimensions()),
    love.graphics.newQuad(128, 0, 128, 128, asteroidSheet:getDimensions()),
    love.graphics.newQuad(0, 128, 128, 128, asteroidSheet:getDimensions()),
    love.graphics.newQuad(128, 128, 128, 128, asteroidSheet:getDimensions()),
}
local particleImage = love.graphics.newImage('assets/img/particle_triangle.png')

-- generates new particles from an asteroid explosion
-- size : 0 (minimal size) - 1 (maximum size)
local function newParticles(x, y, number, size, angle)
    number = number or 16
    return require('entity.ParticleSystem'):new(particleImage, number,
    function() return x end, function() return y end,
    function(ps)
        ps:setParticleLifetime(.1, 1)
        ps:setDirection(angle + math.pi)
        ps:setSpread(math.pi/2)
        ps:setSpeed(50, 300)
        ps:setSpin(-5, 5)
        ps:setSpinVariation(1)
        ps:setSizes(.04 * size, .02 * size, .001 * size)
        ps:setSizeVariation(1)
        ps:setColors(
            161, 160, 156, 255,
            75, 86, 96, 0
        )
        ps:emit(number)
    end)
end


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
    t = t or {}
    local a = Asteroid.newRandom{x = 0, y=0, angle=lume.random(2*math.pi), z=t.z}
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

function Asteroid:split(damager)
    -- if asteroid is big enough, break it into pieces
    local angle = lume.angle(self.x, self.y, damager.x, damager.y)
    local left = Asteroid.newRandom{
        x = self.x, y = self.y,
        angle = angle + math.pi/2, radius = self.radius/2
    }
    local right = Asteroid.newRandom{
        x = self.x, y = self.y,
        angle = angle - math.pi/2, radius = self.radius/2
    }
    local ps = newParticles(self.x, self.y,
        lume.lerp(1, 16, (self.radius/30)^2),
        lume.lerp(.1, 1, self.radius/30), angle
    )
    local divides = self.radius/2 >= Asteroid.dieRadius
    return divides and left or nil, divides and right or nil, ps
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
