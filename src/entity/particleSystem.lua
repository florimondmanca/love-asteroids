local particleSystem = {}

function particleSystem.new(texture, buffer, getX, getY, initFunc)
    local ps = {system = love.graphics.newParticleSystem(texture, buffer)}

    initFunc(ps.system)

    function ps:update(dt)
        ps.system:update(dt)
        if ps.system:getCount() == 0 then
            require('scenes.game'):removeParticleSystem(ps)
        end
    end

    function ps:draw()
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.system, getX(), getY())
    end

    function ps:stop() self.system:stop() end

    return require('scenes.game'):addParticleSystem(ps)
end

return particleSystem
