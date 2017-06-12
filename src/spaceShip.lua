local lume = require 'lib.lume'

local w, h = love.graphics.getDimensions()

local spaceShip = {
    -- translation physics
    mass = .4,
    x = w/2,
    y = h/2,
    vx = 0,
    vy = 0,
    maxSpeed = 150,
    fx = 0,
    fy = 0,
    accForce = 200,
    -- rotation physics
    inertia = 2,
    angle = 0,
    cos = 1,
    sin = 0,
    omega = 0,
    maxOmega = 2.5,
    torque = 0,
    accTorque = 30,
    --
    image = love.graphics.newImage('assets/img/spaceship.png'),
}

--- adds a force in the cartesian frame of reference
function spaceShip:addForce(fx, fy)
    self.fx = self.fx + (fx or 0)
    self.fy = self.fy + (fy or 0)
end

--- adds a force in the spaceship's frame of reference
-- fPar : force in the direction of movement
-- fOrth : force perpendicular to the direction of movement
function spaceShip:addForceV(fPar, fOrth)
    fPar = fPar or 0
    fOrth = fOrth or 0
    self.fx = self.fx + (fPar * self.cos - fOrth * self.sin)
    self.fy = self.fy + (fPar * self.sin + fOrth * self.cos)
end

function spaceShip:addTorque(t)
    self.torque = self.torque + t
end

function spaceShip:update(dt)
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

function spaceShip:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.draw(self.image, -self.image:getWidth()/2, -self.image:getHeight()/2)
    love.graphics.pop()
end

return spaceShip
