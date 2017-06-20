local lume = require 'lib.lume'
local Shot = require 'entity.Shot'

local shooters = {}

local function map(container, func)
    local result = {}
    for _, object in ipairs(container) do table.insert(result, func(object)) end
    return result
end

local function addShotsToScene(shots, scene)
    for _, shot in ipairs(shots) do
        scene:group('shots'):add(shot)
        lume.push(shot.groups, scene:group('shots'))
    end
end

local function spread(angle, width, number)
    local angles = {}
    for i = -math.floor(number/2), math.floor(number/2) do
        table.insert(angles, angle + i * width / number)
    end
    return angles
end

function shooters.simple(x, y, angle, z)
    local shots = {Shot{x=x, y=y, angle=angle, z=z}}
    shots.add = lume.fn(addShotsToScene, shots)
    return shots
end

local function multipleShoots(n)
    return function(x, y, angle, z)
        local shots = map(spread(angle, math.sqrt(n)*math.pi/10, n),
        function(a) return Shot{x=x, y=y, angle=a, z=z} end)
        shots.add = lume.fn(addShotsToScene, shots)
        return shots
    end
end

shooters.triple = multipleShoots(3)
shooters.quint = multipleShoots(5)

return shooters
