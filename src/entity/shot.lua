local class = require 'lib.class'
local lume = require 'lib.lume'

local w, h = love.graphics.getDimensions()

local Shot = class()

Shot:set{
    radius = 3,
    speed = 350,
    lifetime = .8,
    color = {100, 255, 200}
}

function Shot:init(scene, x, y, angle)
    assert(scene, 'scene required')
    assert(x, 'x required')
    assert(y, 'y required')
    assert(angle, 'angle required')
    self.scene = scene
    self.x = x
    self.y = y
    self.vx = self.speed * math.cos(angle)
    self.vy = self.speed * math.sin(angle)
    self.time = 0
end

function Shot:die()
    self.scene:removeShot(self)
end

function Shot:update(dt)
    self.x = lume.loop(self.x + self.vx * dt, 0, w, self.radius)
    self.y = lume.loop(self.y + self.vy * dt, 0, h, self.radius)
    self.time = self.time + dt
    if self.time > self.lifetime then
        self:die()
    end
    self.color = {100, 255, 200, lume.lerp(255, 0, (self.time/self.lifetime)^10)}
end

function Shot:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.radius, 20)
end

function Shot:onMessage(m)
    if m.type == 'collide_asteroid' then
        love.audio.play('assets/audio/asteroid_blowup.wav', 'static', false, .5)
        self:die()
        return true
    end
end


return Shot
