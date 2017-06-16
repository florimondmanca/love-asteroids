local class = require 'lib.class'
local lume = require 'lib.lume'

local QuantityBar = class()
QuantityBar:set{w = 50}

function QuantityBar:init(t)
    assert(t.max, 'max required')
    if not t.min then t.min = 0 end
    self.quantity = lume.clamp(t.initial or t.max, t.min, t.max)
    self.min = t.min
    self.max = t.max
    self.w = t.w or self.w
end

function QuantityBar:draw()
    local xmin, xmax = -self.w/2, self.w/2
    local xq = lume.lerp(xmin, xmax, self.quantity / (self.max - self.min))
    love.graphics.setColor(150, 150, 150)
    love.graphics.rectangle('fill', xmin, -25, self.w, 5)
    love.graphics.setColor(100, 255, 200)
    love.graphics.rectangle('fill', xmin, -25, xq - xmin, 5)
end

function QuantityBar:addQuantity(amount)
    self.quantity = self.quantity + amount
end

return QuantityBar
