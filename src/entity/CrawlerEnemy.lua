local lume = require 'lib.lume'
local SpaceShip = require 'entity.SpaceShip'

local w, h = love.graphics.getDimensions()


local CrawlerEnemy = SpaceShip:extend()

function CrawlerEnemy:init(t)
    t.image = love.graphics.newImage('assets/img/enemy_crawler.png')
    assert(t.speed, 'speed required')
    assert(t.angle, 'angle required')
    assert(type(t.getAim) == 'function', 'CrawlerEnemy requires getAim function')
    t.vx = t.speed * math.cos(t.angle)
    t.vy = t.speed * math.sin(t.angle)
    t.shotGroup = 'shots_enemies'
    SpaceShip.init(self, t)
    self.getAim = function(self) return t.getAim() end
    self.shooter = 'laser_simple'
    self.shootingMean = 4  -- seconds
    self.shootingSigma = 1
    self.nextShoot = lume.randomNormal(self.shootingSigma, self.shootingMean)
    self.time = 0
    self.frictionOn = true
    self:newTarget()
end

function CrawlerEnemy:newTarget()
    self.target = {x = lume.random(50, w - 50), y = lume.random(50, h - 50)}
end

function CrawlerEnemy:externalActions()
    local distance = lume.distance(self.x, self.y, self.target.x, self.target.y)
    self:addForce(
        (self.target.x - self.x) / distance * self.thrust,
        (self.target.y - self.y) / distance * self.thrust
    )
    if distance < 10 then self:newTarget() end
end

local update = CrawlerEnemy.update
function CrawlerEnemy:update(dt)
    update(self, dt)
    self.angle = lume.angle(self.x, self.y, self:getAim())
    self.time = self.time + dt
    if self.time > self.nextShoot then
        self:shoot()
        self.time = 0
        self.nextShoot = lume.randomNormal(self.shootingSigma, self.shootingMean)
    end
end

return CrawlerEnemy
