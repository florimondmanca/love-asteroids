local gamestate = require 'lib.gamestate'
local SceneBuilder = require 'core.SceneBuilder'

local w, h = love.graphics.getDimensions()

local S = SceneBuilder()

S:addObjectAs('logo', {
    x = w/2,
    y = h/2,
    scale = 1,
    image = love.graphics.newImage('assets/img/logo.png'),
    draw = function(self)
        love.graphics.setColor(1, 1, 1)
        love.graphics.push()
        love.graphics.translate(
            self.x - self.image:getWidth()/2 * self.scale,
            self.y - self.image:getHeight()/2 * self.scale)
        love.graphics.scale(self.scale)
        love.graphics.draw(self.image)
        love.graphics.pop()
    end
})

S:addCallback('enter', function(self)
    love.audio.play('assets/audio/asteroids-ost.mp3', 'stream', true, .6)
    love.graphics.setBackgroundColor(0.078, 0.098, 0.137)
    self.objects.timer:script(function(wait)
        self.objects.logo.x = -500
        self.objects.timer:tween(1, self.objects.logo, {x=w/2}, 'out-exp')
        wait(3)
        self.objects.timer:tween(1, self.objects.logo, {x = w+500}, 'in-exp')
        wait(1)
        gamestate.switch(require('scenes/game'):build())
    end)
end)

return S
