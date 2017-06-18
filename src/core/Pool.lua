local class = require 'lib.class'
local lume = require 'lib.lume'

local CALLBACKS = {'update', 'draw', 'mousepressed', 'mousereleased',
'keypressed', 'keyreleased'}

local function defineCallbacks(t)
    for _, fname in ipairs(CALLBACKS) do
        t[fname] = function(self, ...)
            for _, o in pairs(self.objects) do
                if o[fname] then o[fname](o, ...) end
            end
        end
    end
end

local Pool = class()

defineCallbacks(Pool)

function Pool:init()
    self.objects = {}
    self.keys = {}
end

function Pool:add(o)
    if o then self.objects[o] = o end
    return o
end

function Pool:addAs(key, o)
    self.objects[key] = o
    return o
end

function Pool:remove(o)
    lume.remove(self.objects, o)
end

function Pool:each()
    return next, self.objects
end

return Pool
