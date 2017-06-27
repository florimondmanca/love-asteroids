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

function Pool:init(t)
    t = t or {}
    self.objects = {}
    self.z = t.z or 0
end

function Pool:add(o)
    if o then
        if o.z then o.z = o.z + self.z end
        self.objects[o] = o
    end
    return o
end

function Pool:addAs(key, o)
    if o.z then o.z = o.z + self.z end
    self.objects[key] = o
    return o
end

function Pool:remove(o)
    o.dying = true
end

-- called once per frame to remove dead objects
function Pool:flush()
    local dying = lume.any(self.objects, function(o) return o.dying end)
    if dying then
        self.objects = lume.reject(self.objects, function(o) return o.dying end, true)
    end
end

local update = Pool.update
function Pool:update(dt)
    update(self, dt)
    self:flush()
end

function Pool:each()
    return next, self.objects
end

function Pool:fxOn()
    require('core.fxSupport').forObject(self)
end

return Pool
