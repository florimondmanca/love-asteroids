local lume = require 'lib.lume'

-- Simple Observer pattern implementation
-- Register functions to signal identifiers `s` and emit signals through their identifiers

local Signal = {signals = {}}

function Signal.new()
    local self = lume.clone(Signal)
    self.signals = {}
    return self
end

function Signal:register(s, func)
    if not self.signals[s] then self.signals[s] = {} end
    lume.push(self.signals[s], func)
end

function Signal:emit(s, ...)
    for _, func in ipairs(self.signals[s]) do
        func(...)
    end
end

function Signal:remove(s, ...)
    for _, func in ipairs{...} do
        lume.remove(self.signals[s], func)
    end
end

function Signal:clear(s)
    self.signals[s] = {}
end

return Signal
