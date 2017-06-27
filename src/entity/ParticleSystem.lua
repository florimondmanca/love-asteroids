local Entity = require 'core.Entity'

local particleSystem = Entity:extend()

particleSystem.images = {
    circle = love.graphics.newImage('assets/img/particle_circle.png'),
    triangle = love.graphics.newImage('assets/img/particle_triangle.png')
}

function particleSystem:init(texture, buffer, getX, getY, initFunc)
    Entity.init(self)
    self.getX, self.getY = getX, getY
    self.system = love.graphics.newParticleSystem(texture, buffer)
    initFunc(self.system)
end

function particleSystem:update(dt)
    self.system:update(dt)
    if self.system:getCount() == 0 then
        self:kill()
    end
end

function particleSystem:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.system, self.getX(), self.getY())
end

function particleSystem:stop() self.system:stop() end

-- generates new burst of particles
-- size : 0 (minimal size) - 1 (maximum size)
function particleSystem.burst(t)
    t = t or {}
    assert(t.x, 'x required')
    assert(t.y, 'y required')
    assert(t.number, 'number required')
    assert(t.size, 'size required')
    assert(t.colors, 'colors ({r1, g1, b1, r2, g2, b2, ...}) required')
    assert(t.image or t.shape, 'image of shape string must be given')
    assert(not t.shape or particleSystem.images[t.shape], 'unknown particle shape: ' .. tostring(t.shape))
    if type(t.speed) == 'number' then t.speed = {t.speed} end
    if type(t.lifetime) == 'number' then t.lifetime = {t.lifetime} end
    t.spin = t.spin or 0
    t.direction = t.direction or 0

    return particleSystem:new(t.image or particleSystem.images[t.shape], t.number,
    function() return t.x end, function() return t.y end,
    function(ps)
        ps:setParticleLifetime(unpack(t.lifetime or {.1, 1}))
        ps:setDirection(t.direction)
        ps:setSpread(t.spread or 2*math.pi)
        if t.speed then ps:setSpeed(unpack(t.speed)) end
        ps:setSpin(-t.spin, t.spin)
        ps:setSpinVariation(1)
        ps:setSizes(.04 * t.size, .02 * t.size, .001 * t.size)
        ps:setSizeVariation(1)
        ps:setColors(unpack(t.colors))
        ps:emit(t.number)
    end)
end

return particleSystem
