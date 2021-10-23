--[[

DriftingSpaceShip.lua
An enemy drifting in space (constant linear and angular velocity), shots at the player if in its aiming field.

]]--

local lume = require 'lib.lume'
local SpaceShip = require 'entity.spaceship'

local DriftingSpaceShip = SpaceShip:extend()

function DriftingSpaceShip:init(t)
    t.image = love.graphics.newImage('assets/img/enemy_drifting.png')
    assert(t.driftAngle and t.driftSpeed, 'driftAngle, driftSpeed required')
    assert(t.getAim, 'getAim() -> x, y required')
    t.vx = t.driftSpeed * math.cos(t.driftAngle)
    t.vy = t.driftSpeed * math.sin(t.driftAngle)
    t.shotGroup = 'shots_enemies'
    SpaceShip.init(self, t)
    self.getAim = function(self) return t.getAim() end
    self.sight = t.sight or math.pi/20
    self.minShotInterval = t.minShotInterval or 1  -- seconds
    self.shooting = false
end

function DriftingSpaceShip:isInSight(x, y)
    if not x and not y then return false end
    -- vector from self to (x, y)
    local d = {x = x - self.x, y = y - self.y}
    local dot = d.x * self.cos + d.y * self.sin
    local minDot = lume.length(d.x, d.y) * math.cos(self.sight/2)
    return dot >= minDot
end

local update = DriftingSpaceShip.update
function DriftingSpaceShip:update(dt)
    update(self, dt)
    if self:isInSight(self:getAim()) and not self.shooting then
        self:shoot()
        self.shooting = true
        self.timer:after(self.minShotInterval, function() self.shooting = false end)
    end
end

return DriftingSpaceShip
