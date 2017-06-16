local collisions = require 'core.collisions'

local SpaceShip = require 'entity.SpaceShip'
local Asteroid = require 'entity.Asteroid'
local KeyTrigger = require 'core.KeyTrigger'
local Pickup = require 'core.Pickup'
local Timer = require 'core.Timer'

local gameScene = require('core.GameScene'):new()


function gameScene:init()
    self:set('timer', Timer())
    -- object groups
    self:createGroup('shot')
    self:createGroup('asteroid')
    self:createGroup('particleSystem')
    self:createGroup('pickup')

    -- init player's spaceship
    self:set('spaceShip', SpaceShip(self, {health = 5}))
    -- self.objects.spaceShip.shooter = 'triple'

    -- shoot on space key pressed
    self:add(KeyTrigger{key='space', action=function()
        self.objects.spaceShip:shoot()
    end})

    -- create asteroids
    for _ = 1, 30 do
        self:addAsteroid(Asteroid.newRandomAtBorders(self))
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
                -- create a pickup with probability 0.1
                if love.math.random() < .1 then
                    local p = self:addPickup(Pickup(asteroid.x, asteroid.y, function()
                        self.objects.spaceShip.shooter = 'triple'
                        self.objects.timer:after(5, function()
                            self.objects.spaceShip.shooter = 'simple'
                        end)
                    end))
                    self.objects.timer:after(5, function()
                        self:removePickup(p)
                    end)
                end
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
    -- check collisions between player and pickups
    for _, pickup in ipairs(self.objects.pickupGroup.objects) do
        if collisions.circleToCircle(pickup, self.objects.spaceShip) then
            pickup:onCollected()
            self:removePickup(pickup)
        end
    end
end

function gameScene:enter()
    love.graphics.setBackgroundColor(40, 45, 55)
end


return gameScene
