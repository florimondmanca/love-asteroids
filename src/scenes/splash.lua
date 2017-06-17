local gamestate = require 'lib.gamestate'

local w, h = love.graphics.getDimensions()

local menuScene = require('core.GameScene'):new()

function menuScene:init()
    self:addAs('logo', {
        x = w/2,
        y = h/2,
        scale = 1,
        image = love.graphics.newImage('assets/img/logo.png'),
        draw = function(self)
            love.graphics.setColor(255, 255, 255)
            love.graphics.push()
            love.graphics.translate(
                self.x - self.image:getWidth()/2 * self.scale,
                self.y - self.image:getHeight()/2 * self.scale)
            love.graphics.scale(self.scale)
            love.graphics.draw(self.image)
            love.graphics.pop()
        end
    })
end

function menuScene:enter()
    love.graphics.setBackgroundColor(40, 45, 55)
    self.objects.timer:after(5, function()
        gamestate.switch(require 'scenes.game')
    end)
    self.objects.logo.x = -500
    self.objects.timer:tween(1, self.objects.logo, {x=w/2}, 'out-exp')
    self.objects.timer:after(4, function()
        self.objects.timer:tween(1, self.objects.logo, {x = w+500}, 'in-exp')
    end)
end

return menuScene
