local lume = require 'lib.lume'
local collisions = require 'core.collisions'

local gameScene = require('core.GameScene').new()

local Timer = require 'core.Timer'


function gameScene:init()
    self:add(Timer)
    -- object groups
    self:createGroup('shot')
    self:createGroup('asteroid')
    self:createGroup('particleSystem')

    -- player's spaceship
    self:set('spaceShip', require 'entity.spaceShip')

    -- [TRIGGER]: create a new shot on pressing space bar
    self:add(
        require('core.KeyTrigger'):setKey('space'):setAction(function()
            -- add a shot
            self:addShot(require('entity.shot').new(
                self.objects.spaceShip.x,
                self.objects.spaceShip.y,
                self.objects.spaceShip.angle
            ))
            -- player a laser sound
            love.audio.play(
                lume.format('assets/audio/shot{n}.wav',
                {n=lume.randomchoice{1, 2, 3}}), 'static', false, .4
            )
        end)
    )

    -- create asteroids
    for _ = 1, 30 do
        self:addAsteroid(require('entity.asteroid').newRandomAtBorders())
    end

    -- update actions
    self:addUpdateAction(function()
        for _, asteroid in ipairs(self.objects.asteroidGroup.objects) do
            -- check collisions between shots and asteroids
            for _, shot in ipairs(self.objects.shotGroup.objects) do
                if collisions.circleToCircle(shot, asteroid) then
                    self.messageQueue:add{from=shot, to=asteroid, type='blowup'}
                    self.messageQueue:add{from=asteroid, to=shot, type='collide_asteroid'}
                end
            end
            -- check collisions between asteroids and the player
            if collisions.circleToCircle(asteroid, self.objects.spaceShip) then
                self.messageQueue:add{
                    from=asteroid, to=self.objects.spaceShip,
                    type='collide_asteroid', data=-1
                }
                self.messageQueue:add{
                    from=gameScene.objects.spaceShip, to=asteroid,
                    type='blowup'
                }
                self.camera:shake(Timer, (asteroid.radius/30)^2)
            end
        end
    end)
end

function gameScene:enter()
    love.graphics.setBackgroundColor(40, 45, 55)
end


return gameScene
