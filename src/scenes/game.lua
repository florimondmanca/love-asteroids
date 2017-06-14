local lume = require 'lib.lume'

local function circleCollide(a, b)
    return (b.x - a.x)^2 + (b.y - a.y)^2 <= (a.radius + b.radius)^2
end

local gameScene = require('core.GameScene').new()

function gameScene.camera:shake(amount, damp)
    amount = amount and lume.clamp(amount, 0, 1) or 0
    damp = damp and lume.clamp(damp, 0, 1) or .3

    local cx, cy = self.x, self.y
    local rad = lume.lerp(0, 10, amount)
    local angle = lume.random(2*math.pi)

    local duration = .5
    -- smoothly bring the camera to the center position
    gameScene.objects.timer:tween(duration, self, {x = cx, y = cy}, 'in-out-quad')
    -- move it randomly for the same amount of time
    gameScene.objects.timer:during(duration,
    function()
        self:move(lume.vector(angle, rad))
        rad = rad * (1 - damp)
        angle = angle + math.pi + math.pi/3 * lume.randomchoice{1, -1}
    end)
end

function gameScene:init()
    self:set('timer', require 'core.Timer')

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
                if circleCollide(shot, asteroid) then
                    self.messageQueue:add{from=shot, to=asteroid, type='blowup'}
                    self.messageQueue:add{from=asteroid, to=shot, type='collide_asteroid'}
                end
            end
            -- check collisions between asteroids and the player
            if circleCollide(asteroid, self.objects.spaceShip) then
                self.messageQueue:add{
                    from=asteroid, to=self.objects.spaceShip,
                    type='collide_asteroid', data=-1
                }
                self.messageQueue:add{
                    from=gameScene.objects.spaceShip, to=asteroid,
                    type='blowup'
                }
                self.camera:shake((asteroid.radius/30)^2)
            end
        end
    end)
end

function gameScene:enter()
    love.graphics.setBackgroundColor(40, 45, 55)
end


return gameScene
