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

local function makeRadiusTableWeightedBySizes(minSize, nSplits)
    local rt = {}
    for i, g in pairs(nSplits) do
        rt[function(t)
            return lume.lerp(minSize * math.pow(2, i-1), minSize * math.pow(2, i), t) - minSize * math.pow(2, i-2)
        end] = g
    end
    return rt
end

--- quick random builder of asteroids
-- number: number of asteroids
-- minSize : threshold size of the asteroids below which they don't split anymore
-- nSplits : a table {numberOfSplits = weight} that gives the repartition of
-- asteroids by their number of splits
local function buildAsteroids(number, minSize, nSplits)
    local asteroids = {}
    local rt = makeRadiusTableWeightedBySizes(minSize, nSplits)
    for _ = 1, number do
        lume.push(asteroids, Asteroid.newRandomAtBorders{
            radius = lume.weightedchoice(rt)(lume.random()),
            dieRadius = minSize
        })
    end
    return asteroids
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

S:addGroup('asteroids', {init=function(group)
    for _, a in ipairs(buildAsteroids(30, 12, {
        [1] = 1,
        [2] = 2,
    })) do group:add(a) end
end})


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

S:addGroup('particleSystems')

S:addGroup('pickups', {z=-1})


S:addGroup('shots_enemies', {z=-2})
S:addGroup('mines_enemies', {z=-2})
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


----------------
-- Collisions --
----------------

local function onPlayerHit(player)
    if player:damage(-1) then
        love.audio.play('assets/audio/player_dead.wav', 'static', false, .7)
    else
        love.audio.play('assets/audio/collision.wav', 'static', false, .4)
    end
end


S:onCollisionBetween{
    groupA = 'asteroids',
    groupB = 'shots_player',
    resolve = function(scene, asteroid, shot)
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
    end,
    collider = collisions.circleToCircle
}

S:onCollisionBetween{
    group = 'mines_enemies',
    object = 'player',
    resolve = function(_, player, mine)
        mine:kill()
        player.timer:during(2, function() player:freeze() end, function() player:unfreeze() end)
    end,
    collider = collisions.circleToCircle
}

S:onCollisionBetween{
    object = 'player',
    group = 'asteroids',
    resolve = function(scene, player, asteroid)
        splitAsteroid(scene, asteroid, player)
        asteroid:kill()
        scene.camera:shake(scene.objects.timer, (asteroid.radius/30)^2)
        onPlayerHit(player)
    end,
    collider = collisions.circleToCircle
}

S:onCollisionBetween{
    object = 'player',
    group = 'shots_enemies',
    resolve = function(_, player, shot)
        shot:kill()
        onPlayerHit(player)
    end,
    collider = collisions.circleToCircle
}

S:onCollisionBetween{
    groupA = 'shots_player',
    groupB = 'enemies',
    resolve = function(scene, shot, enemy)
        shot:kill()
        scene:group('enemies'):remove(enemy)
        love.audio.play('assets/audio/asteroid_blowup.wav', 'static', false, .35)
    end,
    collider = collisions.circleToCircle
}

S:onCollisionBetween{
    object = 'player',
    group = 'pickups',
    resolve = function(scene, player, pickup)
        pickup:onCollected(player)
        scene:group('pickups'):remove(pickup)
    end,
    collider = collisions.circleToCircle,
}

-- S:addEffect(shine.glowsimple{sigma=2})
S:addEffect(shine.vignette{radius=.9, opacity=.5})

S:addCallback('enter', function(self)
    love.graphics.setBackgroundColor(20, 25, 35)
end)


return S
