--[[

DriftingSpaceShip.lua
An enemy drifting in space (constant linear and angular velocity), shots at the player if in its aiming field.

]]--

local lume = require 'lib.lume'
local SpaceShip = require 'entity.SpaceShip'

local DriftingSpaceShip = SpaceShip:extend()

function DriftingSpaceShip:init(t)
    t.image = love.graphics.newImage('assets/img/enemy_drifting.png')
    assert(t.driftAngle and t.driftSpeed, 'driftAngle, driftSpeed required')
    t.vx = t.driftSpeed * math.cos(t.driftAngle)
    t.vy = t.driftSpeed * math.sin(t.driftAngle)
    SpaceShip.init(self, t)
    self.sight = t.sight or math.pi/20
    self.minShotInterval = t.minShotInterval or 1  -- seconds
    self.shooting = false
end

-- can be called on each frame
function DriftingSpaceShip:aimAt(other)
    if self:isInSight(other) and not self.shooting then
        self.aim = {x = other.x, y = other.y}
    end
end

function DriftingSpaceShip:isInSight(other)
    -- vector from self to other
    local d = {x = other.x - self.x, y = other.y - self.y}
    local dot = d.x * self.cos + d.y * self.sin
    local minDot = lume.length(d.x, d.y) * math.cos(self.sight/2)
    return dot >= minDot
end

local update = DriftingSpaceShip.update
function DriftingSpaceShip:update(dt)
    update(self, dt)
    if self.aim then
        self:shoot()
        self.shooting = true
        self.timer:after(self.minShotInterval, function() self.shooting = false end)
    end
    self.aim = nil
end

return DriftingSpaceShip
