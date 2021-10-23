local class = require 'utils.class'
local lume = require 'lib.lume'
local Asteroid = require 'entity.asteroid'

local AsteroidManager = class()

local function makeRadiusTableWeightedBySizes(minSize, nSplitsTable)
    local rt = {}
    for i, g in pairs(nSplitsTable) do
        rt[function(t)
            return lume.lerp(
                minSize * math.pow(2, i),
                minSize * math.pow(2, i + 1), t
            )
        end] = g
    end
    return rt
end

function AsteroidManager:init(t)
    assert(t.scene, 'AsteroidManager requires scene')
    assert(type(t.group) == 'string', 'AsteroidManager requires string group')
    assert(type(t.minSize) == 'number', 'AsteroidManager requires number minSize')
    self.group = t.scene:group(t.group)
    self.minSize = t.minSize
    self.accumulator = 0
    self.time = 0
    self.frequency = t.frequency or 1/3
    self.delay = lume.random(1/self.frequency)
    if t.init then
        for _, asteroid in ipairs(t.init(self)) do
            self.group:add(asteroid)
        end
    end
end

function AsteroidManager.generate(number, minSize, nSplitsTable)
    local asteroids = {}
    local rt = makeRadiusTableWeightedBySizes(minSize, nSplitsTable)
    for _ = 1, number do
        lume.push(asteroids, Asteroid.newRandomAtBorders{
            radius = lume.weightedchoice(rt)(lume.random()),
            dieRadius = minSize
        })
    end
    return asteroids
end

function AsteroidManager.generateOne(minSize, nSplits)
    return AsteroidManager.generate(1, minSize, {[nSplits] = 1})[1]
end

function AsteroidManager:consume()
    if self.accumulator < 2 then return end
    -- Produce a random asteroid here based on the accumulator.
    local maxSplits = math.floor(math.log(self.accumulator)/.693147)
    local nSplits = love.math.random(1, lume.clamp(maxSplits, 0, 4))
    local asteroid = self.generateOne(self.minSize, nSplits)
    self.accumulator = self.accumulator - math.pow(2, nSplits)
    self.group:add(asteroid)
end

function AsteroidManager:refill(number)
    self.accumulator = self.accumulator + number
end

function AsteroidManager:update(dt)
    self.time = self.time + dt
    if self.time > self.delay then
        self:consume()
        self.time = 0
        self.delay = lume.random(1/self.frequency)
    end

end


return AsteroidManager
