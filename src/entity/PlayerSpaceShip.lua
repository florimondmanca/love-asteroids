local lume = require 'lib.lume'
local SpaceShip = require 'entity.SpaceShip'
local QuantityBar = require 'entity.QuantityBar'


local Player = SpaceShip:extend()

function Player:init(t)
    t = lume.merge(t or {}, {
        image = love.graphics.newImage('assets/img/player.png'),
        frictionOn = true
    })
    SpaceShip.init(self, t)
    self.healthBar = QuantityBar(10)
end

function Player:externalActions()
    if love.keyboard.isDown('up') then self:forward() end
    if love.keyboard.isDown('down') then self:backward() end
    if love.keyboard.isDown('right') then self:rotateRight() end
    if love.keyboard.isDown('left') then self:rotateLeft() end
end

local render = Player.render
function Player:render()
    render(self)
    self.healthBar:draw(self.x, self.y + self.radius + 10)
end

function Player:damage(amount)
    self.healthBar:addQuantity(amount)
    if self.healthBar.quantity <= 0 then
        self:resetPos()
        self.healthBar.quantity = self.healthBar.max
        self.shooter = 'simple'
        self.timer:clear()
        return true
    end
end


return Player
