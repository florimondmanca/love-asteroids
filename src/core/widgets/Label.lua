local class = require 'lib.class'

local Label = class()

Label:set{
    text = {
        value = '',
        set = function(self, text, old) return text or old end,
        afterSet = function(self, text)
            self.textObject:set(self.prefix .. text .. self.suffix) end
    }
}

function Label:init(t)
    t = t or {}
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    self.x = t.x
    self.y = t.y
    self.textObject = love.graphics.newText(love.graphics.getFont())
    self.prefix = t.prefix or '' -- printed before the variable text
    self.suffix = t.suffix or '' -- printed after the variable text
    self.text = t.text or ''
end

function Label:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.textObject, self.x, self.y)
end

function Label:setText(text)
    self.text = text or self.text
end

return Label
