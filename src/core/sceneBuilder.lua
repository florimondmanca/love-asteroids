local class = require 'utils.class'
local lume = require 'lib.lume'
local Signal = require 'lib.signal'
local GameScene = require 'core.gamescene'

local function buildObject(container, key, objectTable)
    local object
    if objectTable.arguments and objectTable.script then
        local args = objectTable.arguments
        object = require(objectTable.script)(args)
        for name, fx in pairs(objectTable.effects or {}) do
            object:addEffect(fx, type(name) == 'string' and name or nil)
        end
    else
        object = objectTable
    end
    if type(key) == 'string' then
        container:addAs(key, object)
    else
        container:add(object)
    end
end

local function buildGroup(group, groupTable)
    for key, objectTable in pairs(groupTable.objects or {}) do
        objectTable.z = (objectTable.z or 0) + (groupTable.z or 0)
        buildObject(group, key, objectTable)
    end
end

local Builder = class()

function Builder:init()
    self.funcs = {}  -- list of initializing functions <func(scene)>
    self.scene = GameScene()
    self.defaultCollider = nil
end

function Builder:setDefaultCollider(collider)
    self.defaultCollider = collider
end

function Builder:addProperty(name, pTable)
    lume.push(self.funcs, function(scene)
        scene:set(name, pTable)
    end)
end

function Builder:addGroup(name, groupTable)
    groupTable = groupTable or {}
    local initGroup = function() end
    if groupTable.init then
        initGroup = groupTable.init
    end
    lume.push(self.funcs, function(scene)
        buildGroup(scene:createGroup(name, {z=groupTable.z}), groupTable)
        initGroup(scene:group(name))
    end)
end

function Builder:addObject(objectTable)
    lume.push(self.funcs, function(scene)
        buildObject(scene, nil, objectTable)
    end)
end

function Builder:addObjectAs(name, objectTable)
    lume.push(self.funcs, function(scene)
        buildObject(scene, name, objectTable)
    end)
end

function Builder:addSignalListener(name, listener)
    lume.push(self.funcs, function()
        Signal.register(name, listener)
    end)
end

function Builder:addUpdateAction(action)
    lume.push(self.funcs, function(scene)
        scene:addUpdateAction(action)
    end)
end

local _onObjectCollision = function(a, b, resolve, collider)
    return function(scene)
        if collider(a, b) then resolve(scene, a, b) end
    end
end

local _onObjectGroupCollision = function(object, group, resolve, collider)
    assert(type(group) == 'string', 'group must be a string')
    return function(scene)
        if type(object) == 'string' then object = scene.objects[object] end
        for _, other in scene:group(group):each() do
            _onObjectCollision(object, other, resolve, collider)(scene)
        end
    end
end

local _onGroupCollision = function(groupA, groupB, resolve, collider)
    assert(type(groupA) == 'string', 'groupA must be a string')
    assert(type(groupB) == 'string', 'groupB must be a string')
    return function(scene)
        for _, a in scene:group(groupA):each() do
            _onObjectGroupCollision(a, groupB, resolve, collider)(scene)
        end
    end
end


function Builder:onCollisionBetween(t)
    t.collider = t.collider or self.defaultCollider
    assert(type(t.resolve) == 'function', 'resolve must be a function')
    assert(type(t.collider) == 'function', 'collider must be a function')
    local action
    if t.groupA and t.groupB then
        action = _onGroupCollision(t.groupA, t.groupB, t.resolve, t.collider)
    elseif t.group and t.object then
        action = _onObjectGroupCollision(t.object, t.group, t.resolve, t.collider)
    elseif t.objectA and t.objectB then
        action = _onObjectCollision(t.objectA, t.objectB, t.resolve, t.collider)
    else
        error('Bad onCollision action description: only (groupA, groupB) (group, object) or (objectA, objectB) allowed')
    end
    self:addUpdateAction(action)
end

-- TODO update for moonshine support
-- function Builder:addEffect(effect, name)
--     if not self.scene.effects then self.scene:fxOn() end
--     lume.push(self.funcs, function(scene)
--         scene:addEffect(effect, name)
--     end)
-- end
function Builder.addEffect() end

function Builder:addCallback(name, func)
    lume.push(self.funcs, function(scene)
        scene[name] = func
    end)
end

function Builder:build()
    -- create a new scene subclass
    local funcs = self.funcs
    function self.scene.setup(self_)
        for _, func in ipairs(funcs) do func(self_) end
    end
    return self.scene
end

return Builder
