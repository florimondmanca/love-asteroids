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
    for key, objectTable in pairs(groupTable) do
        buildObject(scene, group, key, objectTable)
    end
end

local Builder = class()

function Builder:init()
    self.elements = {}  -- list of initializing functions f(scene)
end

function Builder:addProperty(name, pTable)
    lume.push(self.elements, function(scene)
        scene:set(name, pTable)
    end)
end

function Builder:addGroup(name, initializer)
    local initFunc
    initializer = initializer or {}
    if type(initializer) == 'table' then
        local groupTable = initializer
        initFunc = function(scene)
            buildGroup(scene, scene:createGroup(name), groupTable)
        end
    elseif type(initializer) == 'function' then
        initFunc = function(scene)
            buildGroup(scene, scene:createGroup(name), {})
            initializer(scene)
        end
    else
        error('Invalid initializer: must be (object descripting) table or function')
    end
    lume.push(self.elements, initFunc)
end

function Builder:addObject(objectTable)
    lume.push(self.elements, function(scene)
        buildObject(scene, scene, nil, objectTable)
    end)
end

function Builder:addObjectAs(name, objectTable)
    lume.push(self.elements, function(scene)
        buildObject(scene, scene, name, objectTable)
    end)
end

function Builder:addSignalListener(name, listener)
    lume.push(self.elements, function()
        Signal.register(name, listener)
    end)
end

function Builder:addUpdateAction(action)
    lume.push(self.elements, function(scene)
        scene:addUpdateAction(action)
    end)
end

function Builder:addEffect(effect, name)
    lume.push(self.elements, function(scene)
        scene:addEffect(effect, name)
    end)
end

function Builder:addCallback(name, func)
    lume.push(self.elements, function(scene)
        scene[name] = func
    end)
end

function Builder:build()
    -- create a new scene subclass
    local scene = GameScene:extend()
    local elements = self.elements
    function scene:setup()
        for _, func in ipairs(elements) do func(self) end
    end
    return scene
end

return Builder
