local lume = require 'lib.lume'
local CALLBACKS = {'update', 'draw', 'mousepressed', 'mousereleased',
'keypressed', 'keyreleased'}


local GameScene = {
    objects = {},
    updateActions = {},
    messageQueue = require 'core.MessageQueue',
    camera = require('core.camera').new(),
}

function GameScene.new()
    local self = lume.clone(GameScene)
    self.objects = {}
    self.updateActions = {}
    self.messageQueue = require 'core.MessageQueue'
    self.camera = require('core.camera').new()
    return self
end

-- love2d callbacks
for _, fname in ipairs(CALLBACKS) do
    GameScene[fname] = function(self, ...)
        for _, o in pairs(self.objects) do
            if o[fname] then o[fname](o, ...) end
        end
    end
end

local update = GameScene.update
function GameScene:update(dt)
    update(self, dt)
    for _, updateAction in ipairs(self.updateActions) do
        updateAction(dt)
    end
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
    lume.push(self.objects, o)
    return o
end

--- adds an object to a labelled group
-- if group doesn't exist, it is created
function GameScene:addTo(group, o)
    if not self.objects[group] then self:set(group, GameScene.group()) end
    self.objects[group]:add(o)
    return o
end

--- registers a labelled object to the GameScene
-- object will be accessible through GameScene.objects.<key> later on
function GameScene:set(key, o)
    self.objects[key] = o
    return o
end

--- removes an object from the GameScene
function GameScene:remove(o)
    lume.remove(self.objects, o)
end

--- removes an object from a labelled group
function GameScene:removeFrom(group, o)
    lume.remove(self.objects[group].objects, o)
end

function GameScene:addUpdateAction(action)
    lume.push(self.updateActions, action)
end

--- creates and returns a new group (does not add register it to the GameScene)
function GameScene.group()
    local group = {objects = {}}
    group.add = GameScene.add
    group.remove = GameScene.remove
    group.set = GameScene.set

    -- define callbacks
    for _, fname in ipairs(CALLBACKS) do
        group[fname] = function(self, ...)
            for _, o in ipairs(self.objects) do
                if o[fname] then o[fname](o, ...) end
            end
        end
    end

    return group
end

--- creates a new group and the associated add/remove helper methods
-- the group name must be singular (e.g. 'enemy', 'flower', etc.)
-- example for an 'enemy' group:
-- GameScene:createGroup('enemy')  -- creates the group
-- GameScene:addEnemy(enemy)  -- adds an enemy to the group 'enemy'
-- GameScene:removeEnemy(enemy)  -- removes an enemy from the group 'enemy'
-- GameScene.objects.enemyGroup.objects  -- access the group's object list
function GameScene:createGroup(name)
    local groupName = name .. 'Group'
    -- create the group
    self:set(groupName, GameScene.group())
    -- create add/remove helper methods
    local capName = name:sub(1, 1):upper() .. name:sub(2)
    self['add' .. capName] = function(self, o) return self:addTo(groupName, o) end
    self['remove' .. capName] = function(self, o) self:removeFrom(groupName, o) end
end


return GameScene
