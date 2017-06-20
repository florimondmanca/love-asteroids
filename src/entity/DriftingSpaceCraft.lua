--[[

DriftingSpaceCraft.lua
An enemy drifting in space (constant linear and angular velocity), shots at the player if in its aiming field.

]]--

local Entity = require 'core.Entity'

local DriftingSpaceCraft = Entity:extend()
DriftingSpaceCraft:set{
    image = love.graphics.newImage('assets/img/drifting_space_craft.png')
}

function DriftingSpaceCraft:init(t)
    Entity.init(self, t)
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    self.x = t.x
    self.y = t.y
    self.image = love.graphics.newImage
end

function DriftingSpaceCraft:render()
end

return DriftingSpaceCraft
