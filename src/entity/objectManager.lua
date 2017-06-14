local lume = require 'lib.lume'

local function circleCollide(a, b)
    return (b.x - a.x)^2 + (b.y - a.y)^2 <= (a.radius + b.radius)^2
end

-- define your object manager here

local manager = require 'core.objectManager'

-- object groups
manager:createGroup('shot')
manager:createGroup('asteroid')
manager:createGroup('particleSystem')

-- player's spaceship
manager:set('spaceShip', require 'entity.spaceShip')

-- [TRIGGER]: create a new shot on pressing space bar
manager:add(
    require('core.keyTrigger'):setKey('space'):setAction(function()
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
                manager.messageQueue:add{from=asteroid, to=shot, type='die'}
            end
        end
        if circleCollide(asteroid, manager.objects.spaceShip) then
            manager.messageQueue:add{from=asteroid, to=manager.objects.spaceShip, type='damage', data=-1}
            manager.messageQueue:add{from=manager.objects.spaceShip, to=asteroid, type='blowup'}
        end
    end
end)

return manager
