-- main.lua

love.math.setRandomSeed(os.time())

love.graphics.setBackgroundColor(30, 35, 45)


-- define objects

local objectManager = require 'objectManager'

objectManager:set('spaceShip', require 'spaceShip')
objectManager:set('shotTrigger', require('keyTrigger'):setKey('space'))

-- create a new shot on pressing space bar
objectManager.objects.shotTrigger:setAction(function()
    objectManager:add(require('shot').new(
        objectManager.objects.spaceShip.x,
        objectManager.objects.spaceShip.y,
        objectManager.objects.spaceShip.angle
    ))
end)

-- create asteroids
objectManager:set('asteroidManager', require 'asteroidManager')
for _ = 1, 10 do
    objectManager.objects.asteroidManager:create()
end

-- define love2d callbacks

for _, fname in ipairs({
    'update', 'draw', 'mousepressed', 'mousereleased',
    'keypressed', 'keyreleased',
}) do
    love[fname] = function(...)
        for _, object in pairs(objectManager.objects) do
            if object[fname] then object[fname](object, ...) end
        end
    end
end
