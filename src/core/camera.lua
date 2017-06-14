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

function camera:shake(timer, amount, damp)
    amount = amount and lume.clamp(amount, 0, 1) or 0
    damp = damp and lume.clamp(damp, 0, 1) or .3

    local cx, cy = self.x, self.y
    local rad = lume.lerp(0, 10, amount)
    local angle = lume.random(2*math.pi)

    local duration = .5
    -- smoothly bring the camera to the center position
    timer:tween(duration, self, {x = cx, y = cy}, 'in-out-quad')
    -- move it randomly for the same amount of time
    timer:during(duration,
    function()
        self:move(lume.vector(angle, rad))
        rad = rad * (1 - damp)
        angle = angle + math.pi + math.pi/3 * lume.randomchoice{1, -1}
    end)
end

return camera
