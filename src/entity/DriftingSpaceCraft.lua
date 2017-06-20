--[[

DriftingSpaceCraft.lua
An enemy drifting in space (constant linear and angular velocity), shots at the player if in its aiming field.

]]--

local SpaceShip = require 'entity.SpaceShip'

local DriftingSpaceCraft = SpaceShip:extend()

function DriftingSpaceCraft:init(t)
    t.image = love.graphics.newImage('assets/img/enemy_drifting.png')
    assert(t.driftAngle and t.driftSpeed, 'driftAngle, driftSpeed required')
    t.vx = t.driftSpeed * math.cos(t.driftAngle)
    t.vy = t.driftSpeed * math.sin(t.driftAngle)
    SpaceShip.init(self, t)
end

return DriftingSpaceCraft
