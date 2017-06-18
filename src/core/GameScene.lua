local class = require 'lib.class'
local lume = require 'lib.lume'

local MessageQueue = require 'core.MessageQueue'
local Camera = require 'core.Camera'

local CALLBACKS = {'update', 'draw', 'mousepressed', 'mousereleased',
'keypressed', 'keyreleased'}

local GameScene = class()

function GameScene:init()
    self.objects = {}
    self.groups = {}
    self.messageQueue = MessageQueue()
    self.updateActions = {}
    self.camera = Camera()
    self:addAs('timer', require('core.Timer').global)
    self:setup()
end

-- callback called in :init()
function GameScene:setup() end

-- love2d callbacks
for _, fname in ipairs(CALLBACKS) do
    GameScene[fname] = function(self, ...)
        for _, o in pairs(self.objects) do
            if o[fname] then o[fname](o, ...) end
        end
        for _, g in pairs(self.groups) do
            if g[fname] then g[fname](g, ...) end
        end
    end
end

function GameScene:addUpdateAction(action)
    lume.push(self.updateActions, action)
end

local update = GameScene.update
function GameScene:update(dt)
    update(self, dt)
    for _, action in ipairs(self.updateActions) do action(self) end
    self.messageQueue:dispatch()
end

local draw = GameScene.draw
function GameScene:draw()
    self.camera:set()
    draw(self)
    self.camera:unset()
end

--- registers an object to the GameScene
function GameScene:add(o)
    return lume.push(self.objects, o)
end

--- registers a labelled object to the GameScene
-- object will be accessible through GameScene.objects.<key> later on
function GameScene:addAs(key, o)
    self.objects[key] = o
    return o
end

--- removes an object from the GameScene
function GameScene:remove(o)
    lume.remove(self.objects, o)
end

--- creates and returns a new group (does not add register it to the GameScene)
function GameScene.group()
    local group = {objects = {}}
    group.add = GameScene.add
    group.addAs = GameScene.addAs
    group.remove = GameScene.remove

    -- define callbacks
    for _, fname in ipairs(CALLBACKS) do
        group[fname] = function(self, ...)
            for _, o in pairs(self.objects) do
                if o[fname] then o[fname](o, ...) end
            end
        end
    end

    return group
end

--- creates a new group and the associated add/remove helper methods
function GameScene:createGroup(name)
    self.groups[name] = GameScene.group()
    return self.groups[name]
end

function GameScene:sendMessage(t) self.messageQueue:add(t) end

return GameScene
