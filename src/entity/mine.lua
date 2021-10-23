local lume = require 'lib.lume'
local Entity = require 'core.entity'

local w, h = love.graphics.getDimensions()

local Mine = Entity:extend()

Mine:set{
    radius = 6,
    color = {255, 255, 200}
}

function Mine:init(t)
    Entity.init(self, t)
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    self.x = t.x
    self.y = t.y
    self.speed = t.speed or 0
    self.angle = t.angle or 0
    self.omega = t.omega or 0
    self.radius = t.radius or 32
    self.coreRadius = 6
    self.vx = self.speed * math.cos(self.angle)
    self.vy = self.speed * math.sin(self.angle)
    self.color = t.color or self.color
end

function Mine:update(dt)
    self.x = lume.loop(self.x + self.vx * dt, 0, w, self.radius)
    self.y = lume.loop(self.y + self.vy * dt, 0, h, self.radius)
    self.angle = (self.angle + self.omega * dt) % (2*math.pi)
end

function Mine:draw()
    love.graphics.setColor({1, 0.4, 0.58})
    love.graphics.circle('fill', self.x, self.y, self.coreRadius, 20)
    love.graphics.setColor({0.78, 0.27, 0.47})
    love.graphics.setLineWidth(1)
    love.graphics.circle('line', self.x, self.y, self.radius, 20)
end

return Mine
