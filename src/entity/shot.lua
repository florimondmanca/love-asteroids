local lume = require 'lib.lume'

local w, h = love.graphics.getDimensions()

local shot = {
    name = 'Shot',
    radius = 3,
    speed = 350,
    lifetime = .8,
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
    return self
end

function shot:die()
    require('entity.objectManager'):removeShot(self)
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
