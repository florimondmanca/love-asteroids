local class = require 'lib.class'
local lume = require 'lib.lume'
local Signal = require 'lib.signal'
local GameScene = require 'core.GameScene'

local function buildObject(scene, container, key, objectTable)
    local object
    if objectTable.arguments and objectTable.script then
        local args = objectTable.arguments
        if type(args) == 'function' then args = args(scene) end
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

local function buildGroup(scene, group, groupTable)
    for key, objectTable in pairs(groupTable.objects or {}) do
        objectTable.z = (objectTable.z or 0) + (groupTable.z or 0)
        buildObject(scene, group, key, objectTable)
    end
end

local Builder = class()

function Builder:init()
    self.funcs = {}  -- list of initializing functions <func(scene)>
    self.scene = GameScene:extend()
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
        buildGroup(scene, scene:createGroup(name, {z=groupTable.z}), groupTable)
        initGroup(scene:group(name))
    end)
end

function Builder:addObject(objectTable)
    lume.push(self.funcs, function(scene)
        buildObject(scene, scene, nil, objectTable)
    end)
end

function Builder:addObjectAs(name, objectTable)
    lume.push(self.funcs, function(scene)
        buildObject(scene, scene, name, objectTable)
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

function Builder:addEffect(effect, name)
    lume.push(self.funcs, function(scene)
        scene:addEffect(effect, name)
    end)
end

function Builder:addCallback(name, func)
    lume.push(self.funcs, function(scene)
        scene[name] = func
    end)
end

function Builder:build()
    -- create a new scene subclass
    local funcs = self.funcs
    function self.scene:setup()
        for _, func in ipairs(funcs) do func(self) end
    end
    return self.scene
end

return Builder
