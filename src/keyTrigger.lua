local keyTrigger = {
    key = nil,
    action = function() end
}

function keyTrigger:setKey(key) self.key = key return self end
function keyTrigger:setAction(action) self.action = action return self end

function keyTrigger:keypressed(key)
    if key == self.key then self.action() end
end

return keyTrigger
