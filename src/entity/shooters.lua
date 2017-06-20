local lume = require 'lib.lume'
local Shot = require 'entity.Shot'

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
    return function(x, y, angle, z)
        return bundle(lume.map(
            spread(angle, math.sqrt(n)*math.pi/10, n),
            function(a) return Shot{x=x, y=y, angle=a, z=z} end
        ))
    end
end

function shooters.simple(x, y, angle, z)
    return bundle{Shot{x=x, y=y, angle=angle, z=z}}
end

shooters.triple = multipleShooter(3)
shooters.quint = multipleShooter(5)

return shooters
