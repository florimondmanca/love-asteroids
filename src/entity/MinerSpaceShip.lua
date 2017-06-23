--[[

MinerSpaceShip.lua
An enemy drifting in space (constant linear and angular velocity), shots at the player if in its aiming field.

]]--

local lume = require 'lib.lume'
local SpaceShip = require 'entity.SpaceShip'

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
end

local update = MinerSpaceShip.update
function MinerSpaceShip:update(dt)
    update(self, dt)
    if lume.random() < .01 then
        self:shoot()
    end
end

return MinerSpaceShip
