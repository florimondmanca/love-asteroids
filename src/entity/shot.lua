local lume = require 'lib.lume'
local Entity = require 'core.Entity'

local timer = require('core.Timer').global
local w, h = love.graphics.getDimensions()

local Shot = Entity:extend()

Shot:set{
    radius = 3,
    speed = 350,
    lifetime = .8,
    color = {100, 255, 200}
}

function Shot:init(t)
    Entity.init(self, t)
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    assert(t.angle, 'angle required')
    self.x = t.x
    self.y = t.y
    self.vx = self.speed * math.cos(t.angle)
    self.vy = self.speed * math.sin(t.angle)
    self.color = t.color or self.color
    self.time = 0
    self.opacity = 255
    timer:after(.7*self.lifetime, function()
        timer:tween(.3*self.lifetime, self, {opacity = 0}, 'in-exp')
    end)
end

function Shot:update(dt)
    self.x = lume.loop(self.x + self.vx * dt, 0, w, self.radius)
    self.y = lume.loop(self.y + self.vy * dt, 0, h, self.radius)
    self.time = self.time + dt
    self.color = {100, 255, 200, self.opacity}
    if self.time > self.lifetime then
        self:kill()
    end
end

function Shot:render()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.radius, 20)
end


return Shot
