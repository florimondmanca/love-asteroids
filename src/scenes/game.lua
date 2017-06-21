local Signal = require 'lib.signal'
local lume = require 'lib.lume'
local Asteroid = require 'entity.Asteroid'
local Pickup = require 'entity.Pickup'
local collisions = require 'core.collisions'
local SceneBuilder = require 'core.SceneBuilder'
local shine = require 'lib.shine'

local w, h = love.graphics.getDimensions()

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
S:addSignalListener('changed_score', function(scene, score)
    scene:group('widgets').objects.scoreLabel:setText(tostring(score))
end)


S:addGroup('shots_player')
S:addObjectAs('player', {
    script = 'entity.PlayerSpaceShip',
    arguments = {
        x = w/2, y = h/2,
        scene = S.scene,
        health = 5,
        shotColor = {200, 255, 120, 255},
    }
})
S:addObject{
    script = 'core.KeyTrigger',
    arguments = {
        key='k', action=function() S.scene.objects.player:damage(-1) end
    }
}

S:addGroup('particleSystems')

S:addGroup('pickups', {z=-1})

S:addGroup('asteroids', {init=function(group)
    for _ = 1, 10 do group:add(Asteroid.newRandomAtBorders()) end
end})


S:addGroup('shots_enemies')
S:addGroup('enemies', {
    objects = {
        drifting1 = {
            script = 'entity.DriftingSpaceShip',
            arguments = {
                x = lume.random(w), y = lume.random(h), scene = S.scene,
                driftAngle = lume.random(2*math.pi), driftSpeed = 100,
                omega = 2,
                shotColor = {255, 200, 120},
                getAim = function() return S.scene.objects.player.x, S.scene.objects.player.y end
            }
        },
        miner1 = {
            script = 'entity.MinerSpaceShip',
            arguments = {
                x = lume.random(w), y = lume.random(h), scene = S.scene,
                speed = 50, angle = lume.random(2*math.pi),
                omega = lume.random(-2, 2),
            }
        }
    }
})


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


S:addObject{
    script = 'core.KeyTrigger',
    arguments = {key = 'space', action = function()
        Signal.emit('fire_laser', S.scene)
    end}
}
S:addSignalListener('fire_laser', function(scene)
    love.audio.play('assets/audio/shot' .. lume.randomchoice{1, 2, 3} .. '.wav', 'static', false, .5)
    scene.objects.player:shoot()
end)


S:addUpdateAction(function(self)
    -- check collisions between player and pickups
    for _, pickup in self:each('pickups') do
        if collisions.circleToCircle(pickup, self.objects.player) then
            pickup:onCollected(self.objects.player)
            self:group('pickups'):remove(pickup)
        end
    end
end)


S:addUpdateAction(function(self)
    -- check collisions between player's shots and asteroids
    for _, asteroid in self:each('asteroids') do
        for _, shot in self:each('shots_player') do
            if collisions.circleToCircle(shot, asteroid) then
                Signal.emit('collision_asteroid_player_shot', self, asteroid, shot)
            end
        end
    end
end)
S:addSignalListener('collision_asteroid_player_shot', function(scene, asteroid, shot)
    splitAsteroid(scene, asteroid, shot)
    shot:kill()
    asteroid:kill()
    -- increment score
    scene.score = scene.score + asteroid.scorePoints
    -- randomly create a pickup
    if love.math.random() < .1 then
        local p = Pickup{x=asteroid.x, y=asteroid.y}
        p.action = function(spaceShip)
            spaceShip.timer:during(5, function()
                spaceShip.shooter = 'laser_triple'
            end, function() spaceShip.shooter = 'laser_simple' end)
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


S:addUpdateAction(function(self)
    -- check collisions between asteroids and the player
    for _, asteroid in self:each('asteroids') do
        if collisions.circleToCircle(asteroid, self.objects.player) then
            Signal.emit('collision_asteroid_player', self, asteroid, self.objects.player)
        end
    end
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


S:addUpdateAction(function(self)
    -- check collisions between enemies' shots and the player
    for _, shot in self:each('shots_enemies') do
        if collisions.circleToCircle(shot, self.objects.player) then
            Signal.emit('collision_enemyshot_player', self, shot, self.objects.player)
        end
    end
end)
S:addSignalListener('collision_enemyshot_player', function(self, shot, player)
    shot:kill()
    if player:damage(-1) then
        love.audio.play('assets/audio/player_dead.wav', 'static', false, .7)
    else
        love.audio.play('assets/audio/collision.wav', 'static', false, .4)
    end
end)


S:addUpdateAction(function(self)
    -- check collision between player's shots and enemies
    for _, shot in self:each('shots_player') do
        for _, enemy in self:each('enemies') do
            if collisions.circleToCircle(shot, enemy) then
                Signal.emit('collision_playershot_enemy', self, shot, enemy)
            end
        end
    end
end)
S:addSignalListener('collision_playershot_enemy', function(self, shot, enemy)
    shot:kill()
    self:group('enemies'):remove(enemy)
    -- play a sound
    love.audio.play('assets/audio/asteroid_blowup.wav', 'static', false, .35)
end)



S:addEffect(
    shine.glowsimple()
    -- :chain(shine.pixelate{pixel_size=2, samples=1, add_original=true})
    :chain(shine.vignette{radius=.9, opacity=.5})
)

S:addCallback('enter', function(self)
    love.graphics.setBackgroundColor(20, 25, 35)
end)


return S
