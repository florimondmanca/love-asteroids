local Signal = require 'lib.signal'
local lume = require 'lib.lume'
local Asteroid = require 'entity.Asteroid'
local Pickup = require 'entity.Pickup'
local collisions = require 'core.collisions'
local SceneBuilder = require 'core.SceneBuilder'
local shine = require 'lib.shine'

local w, _ = love.graphics.getDimensions()

local function splitAsteroid(self, asteroid, damager)
    local left, right, ps = asteroid:split(damager)
    self:group('asteroids'):add(left)
    self:group('asteroids'):add(right)
    self:group('particleSystems'):add(ps)
end

local S = SceneBuilder()

S:addProperty('score', {
    value = 0,
    get = function(self, value) return value end,
    set = function(self, new) return new end,
    afterSet = function(self, value)
        Signal.emit('changed_score', self, value) end,
})

S:addGroup('shots')
S:addGroup('asteroids', {init=function(group)
    for _ = 1, 30 do
        group:add(Asteroid.newRandomAtBorders())
    end
end})
S:addGroup('particleSystems')
S:addGroup('pickups', {z=-1})
S:addGroup('widgets', {
    objects = {
        scoreLabel = {
            script = 'entity.widgets.Label',
            arguments = {x=50, y=50, text='0', prefix='Score\n'}
        },
        timeCounter = {
            script = 'entity.widgets.TimeCounter',
            arguments = {x = w-100, y = 50}
        }
    }
})

S:addObjectAs('spaceShip', {
    script = 'entity.SpaceShip',
    arguments = function(self) return {scene = self, health = 5} end
})
S:addObject{
    script = 'core.KeyTrigger',
    arguments = function(self) return {key = 'space', action = function()
        Signal.emit('fire_laser', self)
    end} end
}

S:addSignalListener('fire_laser', function(scene)
    love.audio.play('assets/audio/shot' .. lume.randomchoice{1, 2, 3} .. '.wav', 'static', false, .5)
    scene.objects.spaceShip:shoot()
end)

S:addSignalListener('collision_asteroid_shot', function(scene, asteroid, shot)
    splitAsteroid(scene, asteroid, shot)
    shot:kill()
    asteroid:kill()
    -- increment score
    scene.score = scene.score + asteroid.scorePoints
    -- randomly create a pickup
    if love.math.random() < .1 then
        local p = Pickup{x=asteroid.x, y=asteroid.y}
        p.action = function(spaceShip)
            scene.objects.spaceShip.timer:during(5, function()
                spaceShip.shooter = 'triple'
            end, function() spaceShip.shooter = 'simple' end)
        end
        p.lifetime = 5
        scene:group('pickups'):add(p)
        scene.objects.timer:after(p.lifetime, function()
            p:kill()
        end)
    end
    -- play a sound
    love.audio.play('assets/audio/asteroid_blowup.wav', 'static', false, .35)
end)

S:addSignalListener('collision_asteroid_player', function(scene, asteroid, player)
    splitAsteroid(scene, asteroid, player)
    asteroid:kill()
    scene.camera:shake(scene.objects.timer, (asteroid.radius/30)^2)
    if player:damage(-1) then
        love.audio.play('assets/audio/player_dead.wav', 'static', false, .7)
    else
        love.audio.play('assets/audio/collision.wav', 'static', false, .4)
    end
end)

S:addSignalListener('changed_score', function(scene, score)
    scene:group('widgets').objects.scoreLabel:setText(tostring(score))
end)

S:addUpdateAction(function(self)
    -- check collisions between shots and asteroids
    for _, asteroid in self:each('asteroids') do
        for _, shot in self:each('shots') do
            if collisions.circleToCircle(shot, asteroid) then
                Signal.emit('collision_asteroid_shot', self, asteroid, shot)
            end
        end
    end
end)

S:addUpdateAction(function(self)
    -- check collisions between asteroids and the player
    for _, asteroid in self:each('asteroids') do
        if collisions.circleToCircle(asteroid, self.objects.spaceShip) then
            Signal.emit('collision_asteroid_player', self, asteroid, self.objects.spaceShip)
        end
    end
end)

S:addUpdateAction(function(self)
    -- check collisions between player and pickups
    for _, pickup in self:each('pickups') do
        if collisions.circleToCircle(pickup, self.objects.spaceShip) then
            pickup:onCollected(self.objects.spaceShip)
            self:group('pickups'):remove(pickup)
        end
    end
end)

S:addEffect(shine.colorgradesimple{grade={1, .95, 1.05}})
S:addEffect(shine.vignette{radius=1, opacity=.5})

S:addCallback('enter', function(self)
    love.graphics.setBackgroundColor(20, 25, 35)
end)

return S
