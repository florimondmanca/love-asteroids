local collisions = require 'core.collisions'
local KeyTrigger = require 'core.KeyTrigger'
local Pickup = require 'core.Pickup'
local SpaceShip = require 'entity.SpaceShip'
local Asteroid = require 'entity.Asteroid'
local Signal = require('lib.signal').new()

local gameScene = require('core.GameScene'):extend()

function gameScene:setup()
    -- self:set{
    --     score = {
    --         value = 0,
    --         get = function(self, value) return value end,
    --         set = function(self, new)
    --             Signal:emit('changed-score', new)
    --             return new end,
    --         add = function(self, more) self:set(self.value + more) end
    --     }
    -- }

    -- object groups
    self:createGroup('shots')
    self:createGroup('asteroids')
    self:createGroup('particleSystems')
    self:createGroup('pickups')
    self:createGroup('widgets')

    -- self.groups.widgets:addAs('scoreLabel', require('core.widgets.TextLabel'){text=''})

    -- Signal:register('changed-score', function(score)
    --     self.groups.widgets
    --         .objects.scoreLabel:setText(tostring(score))
    -- end)

    -- init player's spaceship
    self:addAs('spaceShip', SpaceShip(self, {health = 5}))

    -- shoot on space key pressed
    self:add(KeyTrigger{key='space', action=function()
        self.objects.spaceShip:shoot()
    end})

    -- create asteroids
    for _ = 1, 30 do
        self.groups.asteroids:add(Asteroid.newRandomAtBorders(self))
    end
end

local update = gameScene.update
function gameScene:update(dt)
    update(self, dt)
    -- check collisions between shots and asteroids
    for _, asteroid in ipairs(self.groups.asteroids.objects) do
        for _, shot in ipairs(self.groups.shots.objects) do
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
                    self.groups.pickups:add(p)
                    self.objects.timer:after(p.lifetime, function()
                        self.groups.pickups:remove(p)
                    end)
                end
            end
        end

    end
    -- check collisions between asteroids and the player
    for _, asteroid in ipairs(self.groups.asteroids.objects) do
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
    for _, pickup in ipairs(self.groups.pickups.objects) do
        if collisions.circleToCircle(pickup, self.objects.spaceShip) then
            pickup:onCollected(self.objects.spaceShip)
            self.groups.pickups:remove(pickup)
        end
    end
end

function gameScene:enter()
    love.graphics.setBackgroundColor(40, 45, 55)
end


return gameScene
