local lume = require 'lib.lume'

local w, h = love.graphics.getDimensions()
-- local particleImage = love.graphics.newImage('assets/img/particle_circle.png')

local shot = {
    name = 'Shot',
    radius = 3,
    speed = 350, -- px/s
    lifetime = .8, -- seconds
    time = 0,
    color = {100, 255, 200}
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
    -- self.ps = require('entity.particleSystem').new(particleImage, 128,
    -- function() return self.x end, function() return self.y end,
    -- function(ps)
    --     ps:setEmissionRate(128)
    --     ps:setParticleLifetime(.1, .5)
    --     ps:setDirection(angle + math.pi)
    --     ps:setSpread(math.pi/10)
    --     ps:setSpeed(200)
    --     ps:setSizes(.01, .005, .001)
    --     ps:setSizeVariation(1)
    --     ps:setColors(100, 255, 200, 255, 100, 255, 200, 0)
    --     ps:emit(1)
    -- end)
    return self
end

function shot:die()
    require('entity.objectManager'):removeShot(self)
    -- self.ps:stop()
end

function shot:update(dt)
    self.x = lume.loop(self.x + self.vx * dt, 0, w, self.radius)
    self.y = lume.loop(self.y + self.vy * dt, 0, h, self.radius)
    self.time = self.time + dt
    if self.time > self.lifetime then
        self:die()
    end
    self.color = {100, 255, 200, lume.lerp(255, 0, (self.time/self.lifetime)^10)}
end

function shot:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.radius, 20)
end

function shot:onMessage(m)
    if m.type == 'collide_asteroid' then
        love.audio.play('assets/audio/asteroid_blowup.wav', 'static', false, .5)
        self:die()
        return true
    end
end

return shot
