local collisions = require 'core.collisions'
local KeyTrigger = require 'core.KeyTrigger'
local Pickup = require 'entity.Pickup'
local SpaceShip = require 'entity.SpaceShip'
local Asteroid = require 'entity.Asteroid'
local Signal = require 'lib.signal'

local w = love.graphics.getDimensions()

local gameScene = require('core.GameScene'):extend()

gameScene:set{
    score = {
        value = 0,
        get = function(self, value) return value end,
        set = function(self, new) return new end,
        afterSet = function(self, value)
            Signal.emit('changed-score', value) end,
    }
}

function gameScene:setup()

    -- object groups
    self:createGroup('shots')
    self:createGroup('asteroids')
    self:createGroup('particleSystems')
    self:createGroup('pickups')
    self:createGroup('widgets')

    self.groups.widgets:addAs('scoreLabel', require('core.widgets.Label'){x=50, y=50, text='0', prefix='Score\n'})
    self.groups.widgets:addAs('timeCounter', require('core.widgets.TimeCounter'){x=w-100, y=50})

    Signal.register('changed-score', function(score)
        self.groups.widgets
            .objects.scoreLabel:setText(tostring(score))
    end)

    -- init player's spaceship
    self:addAs('spaceShip', SpaceShip(self, {health = 5}))

    -- shoot on space key pressed
    self:add(KeyTrigger{key='space', action=function()
        Signal.emit('fire_laser')
    end})

    -- create asteroids
    for _ = 1, 30 do
        self.groups.asteroids:add(Asteroid.newRandomAtBorders(self))
    end

    -- register signals

    Signal.register('collision-asteroid-shot', function(asteroid)
        -- increment score
        self.score = self.score + asteroid.scorePoints
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
    end)

    Signal.register('collision-asteroid-player', function(asteroid)
        self.camera:shake(self.objects.timer, (asteroid.radius/30)^2)
    end)
end

local update = gameScene.update
function gameScene:update(dt)
    update(self, dt)
    -- check collisions between shots and asteroids
    for _, asteroid in ipairs(self.groups.asteroids.objects) do
        for _, shot in ipairs(self.groups.shots.objects) do
            if collisions.circleToCircle(shot, asteroid) then
                Signal.emit('collision-asteroid-shot', asteroid, shot)
            end
        end
    end
    -- check collisions between asteroids and the player
    for _, asteroid in ipairs(self.groups.asteroids.objects) do
        if collisions.circleToCircle(asteroid, self.objects.spaceShip) then
            Signal.emit('collision-asteroid-player', asteroid, self.objects.spaceShip)
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
