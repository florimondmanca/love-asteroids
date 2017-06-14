local lume = require 'lib.lume'

local camera = {
    x = 0,
    y = 0,
    sx = 1,
    sy = 1,
    r = 0,
}

function camera.new() return lume.clone(camera) end

function camera:rotate(dr)
    self.r = self.r + dr
    return self
end

function camera:move(dx, dy)
    self.x = self.x + (dx or 0)
    self.y = self.y + (dy or 0)
    return self
end

function camera:scale(sx, sy)
    sx = sx or 1
    self.sx = self.sx * sx
    self.sy = self.sy * (sy or sx)
    return self
end

function camera:setPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
    return self
end

function camera:setScale(sx, sy)
    self.sx = sx or self.sx
    self.sy = sy or self.sy
    return self
end

function camera:set()
    love.graphics.push()
    love.graphics.rotate(self.r)
    love.graphics.scale(1/self.sx, 1/self.sy)
    love.graphics.translate(self.x, self.y)
end

function camera:unset() love.graphics.pop() end

return camera
