local lume = require 'lib.lume'
local Shot = require 'entity.Shot'
local Mine = require 'entity.Mine'

local shooters = {}

local function addTo(container, shots)
    for _, shot in ipairs(shots) do
        container:add(shot)
        lume.push(shot.groups, container)
    end
end

local function spread(angle, width, number)
    local angles = {}
    for i = -math.floor(number/2), math.floor(number/2) do
        table.insert(angles, angle + i * width / number)
    end
    return angles
end

local function bundle(shots)
    local b = {}
    function b.add(container) addTo(container, shots) end
    function b.setColor(color)
        if color then
            for _, shot in ipairs(shots) do shot.color = color end
        end
        return b
    end
    return b
end

local function multipleShooter(n)
    return function(ship)
        return bundle(lume.map(
            spread(ship.angle, math.sqrt(n)*math.pi/10, n),
            function(a) return Shot{x=ship.x, y=ship.y, angle=a, z=ship.z} end
        ))
    end
end

function shooters.laser_simple(ship)
    return bundle{Shot{x=ship.x, y=ship.y, angle=ship.angle, z=ship.z}}
end

function shooters.mine_simple(ship)
    return bundle{Mine{x=ship.x, y=ship.y, speed=20, angle=ship.angle + math.pi, z=ship.z}}
end

shooters.laser_triple = multipleShooter(3)
shooters.laser_quint = multipleShooter(5)

return shooters
