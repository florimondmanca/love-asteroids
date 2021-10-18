local Entity = require 'core.entity'

local Button = Entity:extend()

function Button:init(t)
    Entity.init(self, t)
    t = t or {}
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    assert(t.h, 'Button requires h')
    assert(t.w, 'Button requires w')
    self.x = t.x
    self.y = t.y
    self.h = t.h
    self.w = t.w
    self.onClick = t.onClick or function() end
    self.onHover = t.onHover or function() end
    self.onUnhover = t.onUnhover or function() end
    self.hover = false
    self.mouseButton = t.mouseButton or 1
    self.color = {255, 255, 255, 255}
end

function Button:mousemoved(x, y)
    local before = self.hover
    self.hover =
        x >= self.x and x <= self.x + self.w
        and y >= self.y and y <= self.y + self.h
    if before and not self.hover then self:onUnhover() end
    if not before and self.hover then self:onHover() end
end

function Button:mousepressed(_, _, button)
    if button == self.mouseButton and self.hover then
        self:onClick()
    end
end

return Button
