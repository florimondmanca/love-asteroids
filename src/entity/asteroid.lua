local lume = require 'lib.lume'

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
    return require('entity.particleSystem').new(particleImage, number,
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


local asteroid = {
    name = 'Asteroid',
    radius = 21,
    speed = 100, -- px/s
    dieRadius = 10,
    omega = 1,
    rotation = 0,
}

function asteroid.new(t)
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    assert(t.angle, 'angle required')
    local self = lume.clone(asteroid)
    -- self.__index = asteroid
    self.x = t.x
    self.y = t.y
    self.speed = t.speed or self.speed
    self.radius = t.radius or self.radius
    self.omega = t.omega or self.omega
    self.rotation = t.rotation or self.rotation
    self.quad = lume.randomchoice(asteroidQuads)
    self.vx = self.speed * math.cos(t.angle)
    self.vy = self.speed * math.sin(t.angle)
    return self
end

function asteroid.newRandom(t)
    t = t or {}
    t.radius = lume.noise(t.radius or asteroid.radius, .2)
    t.speed = lume.noise(t.speed or asteroid.speed, .5)
    t.omega = lume.noise(asteroid.omega, .5)
    t.rotation = lume.random(0, 2*math.pi)
    return asteroid.new(t)
end

function asteroid.newRandomAtBorders()
    local a = asteroid.newRandom{x = 0, y=0, angle=lume.random(2*math.pi)}
    local r = a.radius
    local tlerp = {
        0, (h + 2*r) / (2*w + 2*h + 8*r),
        1/2, (2*h + w + 6*r) / (2*w + 2*h + 8*r), 1
    }
    local t = lume.random()
    a.x = lume.multilerp(tlerp, {-r, -r, w + r, w + r, -r}, t)
    a.y = lume.multilerp(tlerp, {-r, h + r, h + r, -r, -r}, t)
    return a
end

function asteroid:die()
    -- create particles
    require('scenes.game'):removeAsteroid(self)
end

function asteroid:blowup(damager)
    -- if asteroid is big enough, break it into pieces
    local a = lume.angle(self.x, self.y, damager.x, damager.y)
    if self.radius/2 > asteroid.dieRadius then
        require('scenes.game'):addAsteroid(asteroid.newRandom{
            x = self.x, y = self.y,
            angle = a + math.pi/2, radius = self.radius/2
        })
        require('scenes.game'):addAsteroid(asteroid.newRandom{
            x = self.x, y = self.y,
            angle = a - math.pi/2, radius = self.radius/2
        })
    end
    newParticles(self.x, self.y, lume.lerp(1, 16, (self.radius/30)^2), lume.lerp(.1, 1, self.radius/30), a)
    self:die()
end

function asteroid:update(dt)
    -- integrate rotation
    self.rotation = self.rotation + self.omega * dt
    -- integrate translation
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    -- loop through screen
    self.x = lume.loop(self.x, 0, w, self.radius)
    self.y = lume.loop(self.y, 0, h, self.radius)
end

function asteroid:draw()
    love.graphics.setColor(255, 255, 255)
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

function asteroid:onMessage(m)
    if m.type == 'blowup' then
        self:blowup(m.from)
        return true
    end
    if m.type == 'die' then
        self:die()
        return true
    end
end

return asteroid
