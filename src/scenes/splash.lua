local w, h = love.graphics.getDimensions()

local menuScene = require('core.GameScene').new()

menuScene:set('timer', require 'core.Timer')

local spinner = {angle = math.pi/2, span = 0, radius = 50, omega = .5}

function spinner:update(dt)
    self.angle = self.angle + self.omega * dt
end

function spinner:draw()
    love.graphics.setColor(255, 255, 255, 200)
    love.graphics.setLineWidth(10)
    love.graphics.arc('line', 'open', w/2, h/2, self.radius, self.angle, self.angle + self.span)
end

menuScene:set('spinner', spinner)

function menuScene:enter()
    love.graphics.setBackgroundColor(40, 45, 55)
    self.objects.timer:tween(5, self.objects.spinner, {span = 2*math.pi}, 'in-out-quad')
end



return menuScene
