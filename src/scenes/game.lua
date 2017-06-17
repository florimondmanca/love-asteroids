local collisions = require 'core.collisions'

local SpaceShip = require 'entity.SpaceShip'
local Asteroid = require 'entity.Asteroid'
local KeyTrigger = require 'core.KeyTrigger'
local Pickup = require 'core.Pickup'

local gameScene = require('core.GameScene'):extend()

function gameScene:setup()
    -- object groups
    self:createGroup('shot')
    self:createGroup('asteroid')
    self:createGroup('particleSystem')
    self:createGroup('pickup')

    -- init player's spaceship
    self:addAs('spaceShip', SpaceShip(self, {health = 5}))

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
                self:sendMessage{from=shot, to=asteroid, subject='blowup'}
                self:sendMessage{from=asteroid, to=shot, subject='collide_asteroid'}
                -- randomly create a pickup
                if love.math.random() < .1 then
                    local p = Pickup(asteroid.x, asteroid.y)
                    p.action = function(spaceShip)
                        spaceShip.shooter = 'triple'
                        self.objects.timer:after(5, function()
                            spaceShip.shooter = 'simple'
                        end)
                    end
                    p.lifetime = 5
                    self:addPickup(p)
                    self.objects.timer:after(p.lifetime, function()
                        self:removePickup(p)
                    end)
                end
            end
        end

    end
    -- check collisions between asteroids and the player
    for _, asteroid in ipairs(self.objects.asteroidGroup.objects) do
        if collisions.circleToCircle(asteroid, self.objects.spaceShip) then
            self:sendMessage{
                from=asteroid, to=self.objects.spaceShip,
                subject='collide_asteroid', data=-1
            }
            self:sendMessage{
                from=gameScene.objects.spaceShip, to=asteroid,
                subject='blowup'
            }
            self.camera:shake(self.objects.timer, (asteroid.radius/30)^2)
        end
    end
    -- check collisions between player and pickups
    for _, pickup in ipairs(self.objects.pickupGroup.objects) do
        if collisions.circleToCircle(pickup, self.objects.spaceShip) then
            pickup:onCollected(self.objects.spaceShip)
            self:removePickup(pickup)
        end
    end
end

function gameScene:enter()
    love.graphics.setBackgroundColor(40, 45, 55)
end


return gameScene
