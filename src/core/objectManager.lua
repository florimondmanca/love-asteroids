local lume = require 'lib.lume'
local CALLBACKS = {'update', 'draw', 'mousepressed', 'mousereleased',
'keypressed', 'keyreleased'}


local manager = {
    objects = {},
    updateActions = {},
    messageQueue = require 'core.messageQueue',
    camera = require('core.camera').new(),
}

-- love2d callbacks
for _, fname in ipairs(CALLBACKS) do
    manager[fname] = function(self, ...)
        for _, o in pairs(self.objects) do
            if o[fname] then o[fname](o, ...) end
        end
    end
end

local update = manager.update
function manager:update(dt)
    update(self, dt)
    for _, updateAction in ipairs(self.updateActions) do
        updateAction(dt)
    end
    self.messageQueue:dispatch()
end

local draw = manager.draw
function manager:draw()
    self.camera:set()
    draw(self)
    self.camera:unset()
end

--- registers an object to the manager
function manager:add(o)
    lume.push(self.objects, o)
    return o
end

--- adds an object to a labelled group
-- if group doesn't exist, it is created
function manager:addTo(group, o)
    if not self.objects[group] then self:set(group, manager.group()) end
    self.objects[group]:add(o)
    return o
end

--- registers a labelled object to the manager
-- object will be accessible through manager.objects.<key> later on
function manager:set(key, o)
    self.objects[key] = o
    return o
end

--- removes an object from the manager
function manager:remove(o)
    lume.remove(self.objects, o)
end

--- removes an object from a labelled group
function manager:removeFrom(group, o)
    lume.remove(self.objects[group].objects, o)
end

function manager:addUpdateAction(action)
    lume.push(self.updateActions, action)
end

--- creates and returns a new group (does not add register it to the manager)
function manager.group()
    local group = {objects = {}}
    group.add = manager.add
    group.remove = manager.remove
    group.set = manager.set

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
-- manager:createGroup('enemy')  -- creates the group
-- manager:addEnemy(enemy)  -- adds an enemy to the group 'enemy'
-- manager:removeEnemy(enemy)  -- removes an enemy from the group 'enemy'
-- manager.objects.enemyGroup.objects  -- access the group's object list
function manager:createGroup(name)
    local groupName = name .. 'Group'
    -- create the group
    self:set(groupName, manager.group())
    -- create add/remove helper methods
    local capName = name:sub(1, 1):upper() .. name:sub(2)
    self['add' .. capName] = function(self, o) return self:addTo(groupName, o) end
    self['remove' .. capName] = function(self, o) self:removeFrom(groupName, o) end
end


return manager
