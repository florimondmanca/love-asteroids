local class = require 'lib.class'

local Label = class()

Label:set{
    text = {
        value = '',
        set = function(self, text, old)
            text = text or old
            self.textObject:set(text)
            return text end
    }
}

function Label:init(t)
    t = t or {}
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    t.text = t.text or ''
    self.x = t.x
    self.y = t.y
    self.textObject = love.graphics.newText(love.graphics.getFont())
    self.text = t.text
end

function Label:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.textObject, self.x, self.y)
end

function Label:setText(text)
    self.text = text or self.text
end

return Label
