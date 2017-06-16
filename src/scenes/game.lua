local collisions = require 'core.collisions'

local SpaceShip = require 'entity.SpaceShip'
local Asteroid = require 'entity.asteroid'
local KeyTrigger = require 'core.KeyTrigger'
local Timer = require 'core.Timer'

local gameScene = require('core.GameScene'):new()


function gameScene:init()
    self:set('timer', Timer())
    -- object groups
    self:createGroup('shot')
    self:createGroup('asteroid')
    self:createGroup('particleSystem')

    -- init player's spaceship
    self:set('spaceShip', SpaceShip{health=5})

    -- shoot on space key pressed
    self:add(KeyTrigger{key='space', action=function()
        self.objects.spaceShip:shoot()
    end})

    -- create asteroids
    for _ = 1, 30 do
        self:addAsteroid(Asteroid.newRandomAtBorders())
    end
end

local update = gameScene.update
function gameScene:update(dt)
    update(self, dt)
    -- check collisions between shots and asteroids
    for _, asteroid in ipairs(self.objects.asteroidGroup.objects) do
        for _, shot in ipairs(self.objects.shotGroup.objects) do
            if collisions.circleToCircle(shot, asteroid) then
                self.messageQueue:add{from=shot, to=asteroid, type='blowup'}
                self.messageQueue:add{from=asteroid, to=shot, type='collide_asteroid'}
            end
        end
    end
    -- check collisions between asteroids and the player
    for _, asteroid in ipairs(self.objects.asteroidGroup.objects) do
        if collisions.circleToCircle(asteroid, self.objects.spaceShip) then
            self.messageQueue:add{
                from=asteroid, to=self.objects.spaceShip,
                type='collide_asteroid', data=-1
            }
            self.messageQueue:add{
                from=gameScene.objects.spaceShip, to=asteroid,
                type='blowup'
            }
            self.camera:shake(self.objects.timer, (asteroid.radius/30)^2)
        end
    end
end

function gameScene:enter()
    love.graphics.setBackgroundColor(40, 45, 55)
end


return gameScene
