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
    return function(sc)
        return bundle(lume.map(
            spread(sc.angle, math.sqrt(n)*math.pi/10, n),
            function(a) return Shot{x=sc.x, y=sc.y, angle=a, z=sc.z} end
        ))
    end
end

function shooters.laser_simple(sc)
    return bundle{Shot{x=sc.x, y=sc.y, angle=sc.angle, z=sc.z}}
end

function shooters.mine_simple(sc)
    return bundle{Mine{x=sc.x, y=sc.y, speed=20, angle=sc.angle + math.pi, z=sc.z}}
end

shooters.laser_triple = multipleShooter(3)
shooters.laser_quint = multipleShooter(5)

return shooters
