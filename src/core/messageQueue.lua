local class = require 'lib.class'
local lume = require 'lib.lume'

local MessageQueue = class()

function MessageQueue:init()
    self.messages = {}
end

-- called once per frame
function MessageQueue:dispatch()
    local object
    for _, message in ipairs(self.messages) do
        object = message.to
        if object then
            if object.onMessage then
                local success = object:onMessage(message)
                if not success then
                    print('Warning: ' .. object.name .. ' cannot handle "' .. message.type .. '" messages')
                end
            else
                print('Warning:' .. object .. 'does not have onMessage() method')
            end
        end
    end
    -- reset the queue
    self.messages = {}
end

--- registers a message to the queue
function MessageQueue:add(m)
    assert(m.to, 'message to field required')
    assert(m.from, 'message from field required')
    assert(m.type, 'message type field required')
    lume.push(self.messages, m)
end

return MessageQueue
