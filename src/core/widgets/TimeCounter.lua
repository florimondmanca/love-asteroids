local class = require 'lib.class'

local TimeCounter = class()

local function clockTime(seconds)
    seconds = tonumber(seconds)
    if seconds <= 0 then
        return '00:00'
    else
        local mins = string.format('%02.f', math.floor(seconds/60))
        local secs = string.format('%02.f', math.floor(seconds - mins*60))
        return mins .. ':' .. secs
    end
end

function TimeCounter:init(t)
    t = t or {}
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    self.time = t.time or 0
    self.x = t.x
    self.y = t.y
    self.textObject = love.graphics.newText(love.graphics.getFont())
end

function TimeCounter:update(dt)
    self.time = self.time + dt
    self.textObject:set(clockTime(self.time))
end

function TimeCounter:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.textObject, self.x, self.y)
end

return TimeCounter
