local lume = require 'lib.lume'
local gamestate = require 'lib.gamestate'
local Pickup = require 'entity.Pickup'
local collisions = require 'core.collisions'
local SceneBuilder = require 'core.SceneBuilder'
-- local moonshine = require 'lib.moonshine'

local w, h = love.graphics.getDimensions()

---------------
-- Utilities --
---------------

local function splitAsteroid(self, asteroid, damager)
    local left, right, ps = asteroid:split(damager)
    self:group('asteroids'):add(left)
    self:group('asteroids'):add(right)
    self:group('particleSystems'):add(ps)
    self.objects.asteroid_manager:refill(left and right and 1 or 0)
end


local S = SceneBuilder()


----------------------
-- Objects & Groups --
----------------------


S:addGroup('asteroids')
S:addObjectAs('asteroid_manager', {
    script = 'entity.AsteroidManager',
    arguments = {
        minSize = 12,
        scene = S.scene,
        group = 'asteroids',
        frequency = 2,
        init = function(self)
            return self.generate(20, self.minSize, {
                [0] = 2,
                [1] = 2,
                [2] = 1
            })
        end
    }
})

S:addObjectAs('player', {
    script = 'entity.PlayerSpaceShip',
    arguments = {
        x = w/2, y = h/2,
        scene = S.scene,
        health = 5,
        shotColor = {200, 255, 120, 255},
    }
})
S:addGroup('shots_player')
S:addGroup('particleSystems')
S:addGroup('pickups', {z=-1})
S:addGroup('shots_enemies', {z=-2})
S:addGroup('mines_enemies', {z=-2})
S:addGroup('enemies', {
    objects = {
        miner1 = {
            script = 'entity.MinerSpaceShip',
            arguments = {
                x = lume.random(w), y = lume.random(h), scene = S.scene,
                speed = 50, angle = lume.random(2*math.pi),
                omega = lume.random(-2, 2),
            }
        },
        crawler = {
            script = 'entity.CrawlerEnemy',
            arguments = {
                x = lume.random(w), y = lume.random(h), scene = S.scene,
                speed = 100, angle = lume.random(2*math.pi),
                getAim = function()
                    return S.scene.objects.player.x, S.scene.objects.player.y
                end,
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

S:addProperty('score', {
    value = 0,
    get = function(_, value) return value end,
    set = function(_, new) return new end,
    afterSet = function(self, value)
        self:group('widgets').objects.scoreLabel:setText(tostring(value))
    end
})

S:addObject{
    script = 'core.KeyTrigger',
    arguments = {key = 'space', action = function()
        love.audio.play('assets/audio/shot' .. lume.randomchoice{1, 2, 3} .. '.wav', 'static', false, .5)
        S.scene.objects.player:shoot()
    end}
}

S:addUpdateAction(function(scene)
    if lume.lengthof(scene:group('asteroids').objects) == 0 then
        gamestate.switch(require('scenes/menu'):build())
    end
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

S:setDefaultCollider(collisions.circleToCircle)

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
}

S:onCollisionBetween{
    group = 'mines_enemies',
    object = 'player',
    resolve = function(_, player, mine)
        mine:kill()
        player.timer:during(2, function() player:freeze() end, function() player:unfreeze() end)
    end,
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
}

S:onCollisionBetween{
    object = 'player',
    group = 'shots_enemies',
    resolve = function(scene, player, shot)
        shot:kill()
        scene.camera:shake(scene.objects.timer, .5)
        onPlayerHit(player)
    end,
}

S:onCollisionBetween{
    groupA = 'shots_player',
    groupB = 'enemies',
    resolve = function(scene, shot, enemy)
        shot:kill()
        scene:group('enemies'):remove(enemy)
        love.audio.play('assets/audio/asteroid_blowup.wav', 'static', false, .35)
    end,
}

S:onCollisionBetween{
    object = 'player',
    group = 'pickups',
    resolve = function(scene, player, pickup)
        pickup:onCollected(player)
        scene:group('pickups'):remove(pickup)
    end,
}

-- TODO update for moonshine support
-- S:addEffect(moonshine.effects.vignette{radius=.9, opacity=.5})

S:addCallback('enter', function()
    love.graphics.setBackgroundColor(0.078, 0.098, 0.137)
end)


return S
