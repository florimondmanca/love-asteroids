local lume = require 'lib.lume'
local SpaceShip = require 'entity.spaceship'
local QuantityBar = require 'entity.quantitybar'
local ParticleSystem = require 'entity.particlesystem'


local Player = SpaceShip:extend()

function Player:init(t)
    t = lume.merge(t or {}, {
        image = love.graphics.newImage('assets/img/player.png'),
        frictionOn = true,
        shotGroup = 'shots_player'
    })
    SpaceShip.init(self, t)
    self.healthBar = QuantityBar(t.health)
end

function Player:externalActions()
    if love.keyboard.isDown('up') then self:forward() end
    if love.keyboard.isDown('down') then self:backward() end
    if love.keyboard.isDown('right') then self:rotateRight() end
    if love.keyboard.isDown('left') then self:rotateLeft() end
end

function Player:freeze()
    self.externalActions = function() end
end

function Player:unfreeze()
    self.externalActions = Player.externalActions
end

local draw = Player.draw
function Player:draw()
    draw(self)
    love.graphics.push()
    love.graphics.translate(self.x, self.y - (self.radius + 10))
    self.healthBar:draw()
    love.graphics.pop()
end

function Player:damage(amount)
    self.healthBar:addQuantity(amount)
    if self.healthBar.quantity <= 0 then
        self.scene:group('particleSystems'):add(ParticleSystem.burst{
            shape = 'triangle',
            x = self.x,
            y = self.y,
            number = 16,
            speed = {10, 200},
            lifetime = {.05, .5},
            spin = 4,
            size = .5,
            colors = {
                200, 200, 200, 255,
                200, 120, 100, 150,
                160, 100, 80, 0
            }
        })
        self:resetPos()
        self.healthBar.quantity = self.healthBar.max
        self.shooter = 'laser_simple'
        self:unfreeze()
        self.timer:clear()
        return true
    end
end


return Player
