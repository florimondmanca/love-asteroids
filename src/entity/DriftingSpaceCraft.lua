--[[

DriftingSpaceCraft.lua
An enemy drifting in space (constant linear and angular velocity), shots at the player if in its aiming field.

]]--

local Entity = require 'core.Entity'

local DriftingSpaceCraft = Entity:extend()

function DriftingSpaceCraft:init(t)
    Entity.init(self, t)
end

function DriftingSpaceCraft:render()
end

return DriftingSpaceCraft
