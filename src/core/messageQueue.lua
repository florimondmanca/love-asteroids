local lume = require 'lib.lume'

local messageQueue = {
    messages = {}
}

-- called once per frame
function messageQueue:dispatch()
    local object
    for _, message in ipairs(self.messages) do
        object = message.to
        if object then
            local success = object:onMessage(message)
            if not success then
                print('Warning: ' .. object.name .. 'cannot handle "' .. message.type .. '" messages')
            end
        end
    end
    -- reset the queue
    self.messages = {}
end

--- registers a message to the queue
function messageQueue:add(m)
    assert(m.to, 'message to field required')
    assert(m.from, 'message from field required')
    assert(m.type, 'message type field required')
    lume.push(self.messages, m)
end


return messageQueue
