local gamestate = require 'lib.gamestate'
local lume = require 'lib.lume'
-- local shine = require 'lib.shine'
local SceneBuilder = require 'core.SceneBuilder'
local Asteroid = require 'entity.Asteroid'

local w, h = love.graphics.getDimensions()

local S = SceneBuilder()

S:addGroup('asteroids', {init = function(group)
    for _ = 1, 20 do
        group:add(Asteroid.newRandom{
            x = lume.random(w),
            y = lume.random(h),
            omega = .3,
            speed = 20,
        })
    end
end})

S:addGroup('widgets', {z = 1, init = function(group)
    group:addAs('playLabel', require('entity.widgets.Label'){
        x = 100, y = 100, text = 'Play'
    })
    group:addAs('playButton', require('entity.widgets.Button'){
        x = 100,
        y = 100,
        w = group.objects.playLabel.textObject:getWidth(),
        h = group.objects.playLabel.textObject:getHeight(),
        onClick = function()
            gamestate.switch(require('scenes/splash'):build())
        end,
        onHover = function()
            S.scene:group('widgets').objects.playLabel.color = {255, 0, 0}
        end,
        onUnhover = function()
            S.scene:group('widgets').objects.playLabel.color = {255, 255, 255}
        end,
    })
end})

S:addCallback('enter', function(self)
    love.graphics.setBackgroundColor(20, 25, 35)
end)

return S
