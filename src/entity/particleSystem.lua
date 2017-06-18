local Entity = require 'core.Entity'

local particleSystem = Entity:extend()

function particleSystem:init(texture, buffer, getX, getY, initFunc)
    Entity.init(self)
    self.getX, self.getY = getX, getY
    self.system = love.graphics.newParticleSystem(texture, buffer)
    initFunc(self.system)
end

function particleSystem:update(dt)
    self.system:update(dt)
    if self.system:getCount() == 0 then
        self:kill()
    end
end

function particleSystem:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.system, self.getX(), self.getY())
end

function particleSystem:stop() self.system:stop() end

return particleSystem
