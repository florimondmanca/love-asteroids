local class = require 'lib.class'
local lume = require 'lib.lume'

local CALLBACKS = {
    'update', 'draw',
    'mousepressed', 'mousereleased', 'mousemoved',
    'keypressed', 'keyreleased'
}

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
    o.z = o.z or 0
    if o then
        o.z = o.z + self.z
        self.objects[o] = o
    end
    return o
end

function Pool:addAs(key, o)
    o.z = o.z or 0
    o.z = o.z + self.z
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

function Pool:draw()
    for _, o in ipairs(lume.sort(lume.dict2array(self.objects), 'z')) do
        if o.draw then o.draw(o) end
    end
end
function Pool:fxOn()
    require('core.fxSupport').forObject(self)
end

return Pool
