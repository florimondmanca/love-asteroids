local lume = require 'lib.lume'
local Timer = require 'core.Timer'

local function circleCollide(a, b)
    return (b.x - a.x)^2 + (b.y - a.y)^2 <= (a.radius + b.radius)^2
end

-- define your object manager here

local manager = require 'core.ObjectManager'

manager:set('timer', Timer.new())

function manager.camera:shake(amount, damp)
    amount = amount and lume.clamp(amount, 0, 1) or 0
    damp = damp and lume.clamp(damp, 0, 1) or .3

    local cx, cy = self.x, self.y
    local rad = lume.lerp(0, 10, amount)
    local angle = lume.random(2*math.pi)

    local duration = .5
    -- smoothly bring the camera to the center position
    manager.objects.timer:tween(duration, self, {x = cx, y = cy}, 'in-out-quad')
    -- move it randomly for the same amount of time
    manager.objects.timer:during(duration,
    function()
        self:move(lume.vector(angle, rad))
        rad = rad * (1 - damp)
        angle = angle + math.pi + math.pi/3 * lume.randomchoice{1, -1}
    end)
end

-- object groups
manager:createGroup('shot')
manager:createGroup('asteroid')
manager:createGroup('particleSystem')

-- player's spaceship
manager:set('spaceShip', require 'entity.spaceShip')

-- [TRIGGER]: create a new shot on pressing space bar
manager:add(
    require('core.KeyTrigger'):setKey('space'):setAction(function()
        -- add a shot
        manager:addShot(require('entity.shot').new(
            manager.objects.spaceShip.x,
            manager.objects.spaceShip.y,
            manager.objects.spaceShip.angle
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
    manager:addAsteroid(require('entity.asteroid').newRandomAtBorders())
end

-- update actions
manager:addUpdateAction(function()
    for _, asteroid in ipairs(manager.objects.asteroidGroup.objects) do
        for _, shot in ipairs(manager.objects.shotGroup.objects) do
            if circleCollide(shot, asteroid) then
                manager.messageQueue:add{from=shot, to=asteroid, type='blowup'}
                manager.messageQueue:add{from=asteroid, to=shot, type='collide_asteroid'}
            end
        end
        if circleCollide(asteroid, manager.objects.spaceShip) then
            manager.messageQueue:add{
                from=asteroid, to=manager.objects.spaceShip,
                type='collide_asteroid', data=-1
            }
            manager.messageQueue:add{
                from=manager.objects.spaceShip, to=asteroid,
                type='blowup'
            }
            manager.camera:shake((asteroid.radius/30)^2)
        end
    end
end)

return manager
