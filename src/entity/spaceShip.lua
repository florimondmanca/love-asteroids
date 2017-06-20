local lume = require 'lib.lume'
local Entity = require 'core.Entity'
local Timer = require 'core.Timer'

local shooters = require 'entity.shooters'

local w, h = love.graphics.getDimensions()

local SpaceShip = Entity:extend()

SpaceShip:set{
    radius = {
        get = function(self) return self.image:getWidth()/2 end,
        set = function(self, new) return new end,
    },
    shooter = {
        value = shooters.simple,
        get = function(self, value) return value end,
        set = function(self, shooter)
            if type(shooter) == 'string' then
                return shooters[shooter] or error('No shooter named ' .. tostring(shooter))
            else
                assert(lume.find(shooters, shooter), 'Illegal shooter: ' .. tostring(shooter))
                return shooter
            end
        end
    },
}

function SpaceShip:init(t)
    Entity.init(self, t)
    assert(t.image, 'image required')
    assert(t.scene, 'scene required')
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    assert(t.shotGroup, 'shotGroup required')
    self.image = t.image
    self.scene = t.scene
    self.timer = Timer()
    self.shooter = 'simple'
    self.shotColor = t.shotColor
    self.shotGroup = t.shotGroup
    -- position
    self.x = t.x
    self.x0 = t.x0 or self.x
    self.y = t.y
    self.y0 = t.y0 or self.y
    -- inertia properties
    self.mass = t.mass or 1
    self.inertia = t.inertia or 1
    -- translation physics
    self.vx = t.vx or 0
    self.vy = t.vy or 0
    self.maxSpeed = t.maxSpeed or 200
    self.fx = 0
    self.fy = 0
    self.thrust = t.thrust or 500  -- linear acceleration
    -- rotation physics
    self.angle = t.angle or -math.pi/2
    self.cos = math.cos(self.angle)
    self.sin = math.sin(self.angle)
    self.omega = t.omega or 0
    self.maxOmega = t.maxOmega or 3
    self.torque = 0
    self.rthrust = t.rthrust or 30  -- angular acceleration
    self.frictionOn = t.frictionOn or false
end

function SpaceShip:shoot()
    self.shooter(self.x, self.y, self.angle, self.z)
        .setColor(self.shotColor)
        .add(self.scene:group(self.shotGroup))
end

function SpaceShip:resetPos()
    self.x = self.x0
    self.y = self.y0
    self.vx = 0
    self.vy = 0
end

--- adds a force in the screen frame of reference
function SpaceShip:addForce(fx, fy)
    self.fx = self.fx + (fx or 0)
    self.fy = self.fy + (fy or 0)
end

--- adds a force in the spaceship's frame of reference
function SpaceShip:addForceV(fPar, fOrth)
    fPar = fPar or 0
    fOrth = fOrth or 0
    self.fx = self.fx + (fPar * self.cos - fOrth * self.sin)
    self.fy = self.fy + (fPar * self.sin + fOrth * self.cos)
end

function SpaceShip:forward(strength)
    self:addForceV(self.thrust * (strength or 1))
end
function SpaceShip:backward(strength)
    self:addForceV(-self.thrust * (strength or 1))
end
function SpaceShip:rotateRight(strength)
    self:addTorque(self.rthrust * (strength or 1))
end
function SpaceShip:rotateLeft(strength)
    self:addTorque(-self.rthrust * (strength or 1))
end

function SpaceShip:addTorque(t)
    self.torque = self.torque + t
end

--- SpaceShip:externalActions(dt): callback, called during update(dt)
-- define here external actions that alter the spaceship's dynamical state
function SpaceShip:externalActions() end

function SpaceShip:update(dt)
    self.timer:update(dt)
    self:externalActions(dt)
    -- apply translation and rotation dampening
    if self.frictionOn then
        local a = self.thrust / self.maxSpeed
        self:addForce(-a * self.vx, -a * self.vy)
        local c = self.rthrust / self.maxOmega
        self:addTorque(-c * self.omega)
    end
    -- integrate rotation
    self.omega = self.omega + self.torque * dt / self.inertia
    self.angle = (self.angle + self.omega * dt) % (2*math.pi)
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

function SpaceShip:render()
    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.push()
            love.graphics.rotate(self.angle)
            love.graphics.draw(self.image, -self.image:getWidth()/2, -self.image:getHeight()/2)
        love.graphics.pop()
    love.graphics.pop()
end

--- SpaceShip:damage(amount) : callback, defines what happens when spaceship gets hurt
function SpaceShip:damage() end

return SpaceShip
