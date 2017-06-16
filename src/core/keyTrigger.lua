local class = require 'lib.class'

local KeyTrigger = class()
KeyTrigger:set{
    key = nil,
    action = function() end
}

function KeyTrigger:init(t)
    if t.key then self:set('key', t.key) end
    if t.action then self:set('action', t.action) end
end

function KeyTrigger:keypressed(key)
    if key == self.key then self.action() end
end

return KeyTrigger
