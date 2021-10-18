--[[

MinerSpaceShip.lua
An enemy drifting in space (constant linear and angular velocity), shots at the player if in its aiming field.

]]--

local lume = require 'lib.lume'
local SpaceShip = require 'entity.spaceship'

local MinerSpaceShip = SpaceShip:extend()

function MinerSpaceShip:init(t)
    t.image = love.graphics.newImage('assets/img/enemy_miner.png')
    assert(t.speed, 'speed required')
    assert(t.angle, 'angle required')
    t.vx = t.speed * math.cos(t.angle)
    t.vy = t.speed * math.sin(t.angle)
    t.shotGroup = 'mines_enemies'
    SpaceShip.init(self, t)
    self.shooter = 'mine_simple'
    self.shootingMean = 4  -- seconds
    self.shootingSigma = 1
    self.nextShoot = lume.randomNormal(self.shootingSigma, self.shootingMean)
    self.time = 0
end

local update = MinerSpaceShip.update
function MinerSpaceShip:update(dt)
    update(self, dt)
    self.time = self.time + dt
    if self.time > self.nextShoot then
        self:shoot()
        self.time = 0
        self.nextShoot = lume.randomNormal(self.shootingSigma, self.shootingMean)
    end
end

return MinerSpaceShip
