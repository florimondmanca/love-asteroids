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
    self.toRemove = {}
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
    o.dying = true
end

-- called once per frame
function Pool:flush()
    self.objects = lume.reject(self.objects, function(o) return o.dying end, true)
end

local update = Pool.update
function Pool:update(dt)
    self:flush()
    update(self, dt)
end

function Pool:each()
    return next, self.objects
end

return Pool
