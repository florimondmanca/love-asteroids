-- main.lua

-- initial config
love.math.setRandomSeed(os.time())
love.graphics.setBackgroundColor(40, 45, 55)

-------------
-- Objects --
-------------

local objectManager = require 'objectManager'

-- player's spaceship
objectManager:set('spaceShip', require 'spaceShip')

-- create a new shot on pressing space bar
objectManager:set('shotTrigger', require('keyTrigger'):setKey('space'))
objectManager.objects.shotTrigger:setAction(function()
    objectManager:add(require('shot').new(
        objectManager.objects.spaceShip.x,
        objectManager.objects.spaceShip.y,
        objectManager.objects.spaceShip.angle
    ))
end)

-- create asteroids
local asteroids = objectManager.group()
for _ = 1, 10 do
    asteroids:add(require('asteroid').newRandomAtBorders())
end
objectManager:set('asteroids', asteroids)


----------------------
-- Love2d callbacks --
----------------------

for _, fname in ipairs({
    'update', 'draw', 'mousepressed', 'mousereleased',
    'keypressed', 'keyreleased',
}) do
    love[fname] = function(...)
        for _, o in pairs(objectManager.objects) do
            if o[fname] then o[fname](o, ...) end
        end
    end
end
