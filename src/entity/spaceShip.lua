local class = require 'lib.class'
local lume = require 'lib.lume'

local shooters = require 'entity.shooters'

local QuantityBar = require 'entity.QuantityBar'

local w, h = love.graphics.getDimensions()

local SpaceShip = class()

SpaceShip:set{
    image = love.graphics.newImage('assets/img/spaceship.png'),
    -- body properties
    mass = .4,
    radius = {
        get = function(self) return self.image:getWidth()/2 end,
        set = function(self, new) return new end,
    },
    -- translation physics
    x = w/2,
    y = h/2,
    vx = 0,
    vy = 0,
    maxSpeed = 200,
    fx = 0,
    fy = 0,
    accForce = 200,
    -- rotation physics
    inertia = 1,
    angle = 0,
    cos = 1,
    sin = 0,
    omega = 0,
    maxOmega = 3,
    torque = 0,
    accTorque = 30,
}

function SpaceShip:init(t)
    if t.health then
        if type(t.health) == 'number' then t.health = {max = t.health} end
    end
    self.healthBar = QuantityBar(t.health or {max = 10})
    t.health = nil
    -- update attributes from t
    for k, v in pairs(t) do
        if SpaceShip[k] then self[k] = v
        else print('warning: unknown property ' .. k .. ' for SpaceShip') end
    end
    self.shooter = shooters.simple
end

function SpaceShip:resetPos()
    self.x = w/2
    self.y = h/2
    self.vx = 0
    self.vy = 0
end

--- adds a force in the cartesian frame of reference
function SpaceShip:addForce(fx, fy)
    self.fx = self.fx + (fx or 0)
    self.fy = self.fy + (fy or 0)
end

--- adds a force in the spaceship's frame of reference
-- fPar : force in the direction of movement
-- fOrth : force perpendicular to the direction of movement
function SpaceShip:addForceV(fPar, fOrth)
    fPar = fPar or 0
    fOrth = fOrth or 0
    self.fx = self.fx + (fPar * self.cos - fOrth * self.sin)
    self.fy = self.fy + (fPar * self.sin + fOrth * self.cos)
end

function SpaceShip:addTorque(t)
    self.torque = self.torque + t
end

function SpaceShip:update(dt)
    -- apply forces/torque based on input
    if love.keyboard.isDown('up') then self:addForceV(self.accForce) end
    if love.keyboard.isDown('down') then self:addForceV(-self.accForce) end
    if love.keyboard.isDown('right') then self:addTorque(self.accTorque) end
    if love.keyboard.isDown('left') then self:addTorque(-self.accTorque) end
    -- apply translation and rotation dampening
    local a = self.accForce / self.maxSpeed
    self:addForce(-a * self.vx, -a * self.vy)
    local c = self.accTorque / self.maxOmega
    self:addTorque(-c * self.omega)
    -- integrate rotation
    self.omega = self.omega + self.torque * dt / self.inertia
    self.angle = self.angle + self.omega * dt
    self.cos = math.cos(self.angle)
    self.sin = math.sin(self.angle)
    self.torque = 0
    -- integrate translation
    self.vx = self.vx + self.fx * dt / self.mass
    self.vy = self.vy + self.fy * dt / self.mass
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.fx = 0
    self.fy = 0
    -- loop through screen
    self.x = lume.loop(self.x, 0, w, self.image:getWidth()/2)
    self.y = lume.loop(self.y, 0, h, self.image:getHeight()/2)
end

function SpaceShip:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.push()
            love.graphics.rotate(self.angle)
            love.graphics.draw(self.image, -self.image:getWidth()/2, -self.image:getHeight()/2)
        love.graphics.pop()
        self.healthBar:draw()
    love.graphics.pop()
end

function SpaceShip:shoot()
    self.shooter(self)
    love.audio.play(
        lume.format('assets/audio/shot{n}.wav',
        {n=lume.randomchoice{1, 2, 3}}), 'static', false, .4
    )
end

function SpaceShip:onMessage(m)
    if m.type == 'collide_asteroid' then
        self.healthBar:addQuantity(m.data)
        if self.healthBar.quantity <= 0 then
            love.audio.play('assets/audio/player_dead.wav', 'static', false, .5)
            self:resetPos()
            self.healthBar.quantity = self.healthBar.max
        else
            love.audio.play('assets/audio/collision.wav', 'static', false, .3)
        end
        return true
    end
end


return SpaceShip
