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
    self.effects = {}
    self.keys = {}
    self.toRemove = {}
    self.z = t.z or 0
end

function Pool:add(o)
    if o then
        o.z = (o.z or 0) + self.z
        self.objects[o] = o
    end
    return o
end

function Pool:addAs(key, o)
    o.z = (o.z or 0) + self.z
    self.objects[key] = o
    return o
end

function Pool:addEffect(effect, key)
    if key then self.effects[key] = effect end
    lume.push(self.effects, effect)
end

function Pool:fxOn(func)
    local fx = function(f) f() end
    if #self.effects > 0 then
        fx = lume.reduce(self.effects, function(a, b) return a:chain(b) end)
    end
    fx(func)
end

function Pool:remove(o)
    o.dying = true
end

-- called once per frame
function Pool:flush()
    local dying = lume.any(self.objects, function(o) return o.dying end)
    if dying then
        self.objects = lume.reject(self.objects, function(o) return o.dying end, true)
    end
end

local update = Pool.update
function Pool:update(dt)
    self:flush()
    update(self, dt)
end

-- local draw = Pool.draw
function Pool:draw()
    self:fxOn(function()
        for _, o in ipairs(lume.sort(lume.dict2array(self.objects), 'z')) do
            if o.draw then o.draw(o) end
        end
    end)
end

function Pool:each()
    return next, self.objects
end

return Pool
