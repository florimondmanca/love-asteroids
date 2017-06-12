local lume = require 'lib.lume'

local w, h = love.graphics.getDimensions()

local ts = {0, h / (2*w + 2*h), 1/2, (2*h + w) / (2*w + 2*h), 1}

local manager = {asteroids = {}}

function manager:create()
    local t = love.math.random()
    local a0 = love.math.random() * math.pi
    local angle = math.pi/16 + math.floor(a0/4) * math.pi/8 + a0
    local a = require('asteroid').newRandom(0, 0, angle)
    local r = a.radius
    local x = lume.multilerp(ts, {r, r, w - r, w - r, r}, t)
    local y = lume.multilerp(ts, {r, h - r, h - r, r, r}, t)
    a.x = x
    a.y = y
    lume.push(self.asteroids, a)
end

function manager:remove(asteroid)
    lume.remove(self.asteroids, asteroid)
end

function manager:update(dt)
    for _, a in ipairs(self.asteroids) do a:update(dt) end
end

function manager:draw()
    for _, a in ipairs(self.asteroids) do a:draw() end
end

return manager
