local lume = require 'lib.lume'

local quantityBar = {
    name = 'quantityBar',
    quantity = 0,
    min = 0,
    max = 1,
    w = 50, -- pixels
}

function quantityBar.new(t)
    assert(t.initial, 'initial required')
    assert(t.min, 'min required')
    assert(t.max, 'max required')
    local self = lume.clone(quantityBar)
    self.__index = quantityBar
    self.quantity = t.initial
    self.min = t.min
    self.max = t.max
    self.w = t.w or self.w
    return self
end

function quantityBar:draw()
    local xmin, xmax = -self.w/2, self.w/2
    local xq = lume.lerp(xmin, xmax, self.quantity / (self.max - self.min))
    love.graphics.setColor(150, 150, 150)
    love.graphics.rectangle('fill', xmin, -25, self.w, 5)
    love.graphics.setColor(100, 255, 200)
    love.graphics.rectangle('fill', xmin, -25, xq - xmin, 5)
end

function quantityBar:addQuantity(amount)
    self.quantity = self.quantity + amount
end

return quantityBar
