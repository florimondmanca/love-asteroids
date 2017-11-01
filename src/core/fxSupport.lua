-- TODO update for moonshine support

local lume = require 'lib.lume'

local function chainEffects(self)
    if #self.effects > 0 then
        return lume.reduce(self.effects, function(a, b) return a.chain(b) end)
    end
end

local function drawWithEffects(draw)
    return function(self)
        local fx = chainEffects(self) or function(f) f() end
        fx(function() draw(self) end)
    end
end

return {
    forClass = function(cls)
        local init = cls.init
        function cls:init(t)
            init(self, t)
            self.effects = {}
        end

        function cls:addEffect(fx, name)
            print('adding effect', fx, name, 'to', self.effects)
            if name then self.effects[name] = fx end
            lume.push(self.effects, fx)
        end

        cls:set{
            draw = {
                value = cls.draw,
                get = function(self, value)
                    return value
                end,
                set = function(self, draw)
                    return drawWithEffects(draw)
                end,
            }
        }
    end,

    forObject = function(o)
        o.effects = {}

        function o:addEffect(fx, name)
            if name then self.effects[name] = fx end
            lume.push(self.effects, fx)
        end

        o:set{
            draw = {
                value = drawWithEffects(o.draw),
                get = function(self, value) return value end,
                set = function(self, draw) return drawWithEffects(draw) end
            }
        }
    end,
}
