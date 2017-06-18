local lume = require 'lib.lume'
local Shot = require 'entity.Shot'

local shooters = {}

local function map(container, func)
    local result = {}
    for _, object in ipairs(container) do
        table.insert(result, func(object))
    end
    return result
end

local function add(scene, shots)
    for _, shot in ipairs(shots) do
        scene:group('shots'):add(shot)
        lume.push(shot.groups, scene:group('shots'))
    end
    return shots
end

local function spread(angle, width, number)
    local angles = {}
    for i = -math.floor(number/2), math.floor(number/2) do
        table.insert(angles, angle + i * width / number)
    end
    return angles
end

function shooters.simple(scene, body)
    return add(scene, {Shot(body.x, body.y, body.angle)})
end

function shooters.triple(scene, body)
    return add(scene, map(spread(body.angle, math.pi/6, 3), function(a) return Shot(body.x, body.y, a) end))
end

function shooters.quint(scene, body)
    return add(scene, map(spread(body.angle, math.pi/4, 5), function(a) return Shot(body.x, body.y, a) end))
end

return shooters
