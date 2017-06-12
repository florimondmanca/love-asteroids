local function circleCollide(a, b)
    return (b.x - a.x)^2 + (b.y - a.y)^2 <= (a.radius + b.radius)^2
end

-- define your object manager here

local manager = require 'core.objectManager'

-- object groups
manager:createGroup('shot')
manager:createGroup('asteroid')

-- player's spaceship
manager:set('spaceShip', require 'spaceShip')

-- [TRIGGER]: create a new shot on pressing space bar
manager:add(
    require('keyTrigger'):setKey('space'):setAction(function()
        manager:addShot(require('shot').new(
            manager.objects.spaceShip.x,
            manager.objects.spaceShip.y,
            manager.objects.spaceShip.angle
        ))
    end)
)

-- create asteroids
for _ = 1, 10 do
    manager:addAsteroid(require('asteroid').newRandomAtBorders())
end

-- update actions
manager:addUpdateAction(function()
    for _, asteroid in ipairs(manager.objects.asteroidGroup.objects) do
        for _, shot in ipairs(manager.objects.shotGroup.objects) do
            if circleCollide(shot, asteroid) then
                shot:die()
                asteroid:damage()
            end
        end
    end
end)

return manager
