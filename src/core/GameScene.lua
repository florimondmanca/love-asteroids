local lume = require 'lib.lume'
local Camera = require 'core.Camera'
local Pool = require 'core.Pool'

local GameScene = Pool:extend()

local init = GameScene.init
function GameScene:init()
    init(self)
    self.updateActions = {}
    self.camera = Camera()
    self:addAs('timer', require('core.Timer').global)
    self:setup()
end

--- callback, called in GameScene:init()
function GameScene:setup() end

function GameScene:addUpdateAction(action)
    lume.push(self.updateActions, action)
end

local update = Pool.update
function GameScene:update(dt)
    update(self, dt)
    for _, action in ipairs(self.updateActions) do action(self) end
end

local draw = GameScene.draw
function GameScene:draw()
    self.camera:set()
    draw(self)
    self.camera:unset()
end

--- creates a new group and the associated add/remove helper methods
function GameScene:createGroup(name)
    local group = Pool()
    local add = group.add
    function group:add(o)
        if o then lume.push(o.groups, self) end
        return add(self, o)
    end
    self.objects['group_' .. name] = group
    return group
end

function GameScene:group(name)
    return self.objects['group_' .. name]
end

function GameScene:each(groupName)
    if groupName then return self:group(groupName):each()
    else return next, self.objects end
end

return GameScene
