local class = require 'lib.class'

local particleSystem = class()

function particleSystem:init(scene, texture, buffer, getX, getY, initFunc)
    self.scene = scene
    self.getX, self.getY = getX, getY
    self.system = love.graphics.newParticleSystem(texture, buffer)
    initFunc(self.system)
end

function particleSystem:update(dt)
    self.system:update(dt)
    if self.system:getCount() == 0 then
        self.scene.groups.particleSystems:remove(self)
    end
end

function particleSystem:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.system, self.getX(), self.getY())
end

function particleSystem:stop() self.system:stop() end

return particleSystem
