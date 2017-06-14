local lume = require 'lib.lume'
local easing = require 'core.easing'

-- Generic action handler, basically adds some time context to a function
local Action = {}

function Action.new(func, update)
    local self = lume.clone(Action)
    self.func = func or function() end
    self.elapsed = 0
    self.finished = false
    self.update = update or Action.update
    return self
end

function Action:finish() self.finished = true end
function Action:isFinished() return self.finished end

function Action:update(dt)
    self.elapsed = self.elapsed + dt
end

function Action:call() self.func(self.func) end
function Action:trigger() self:call() self.elapsed = 0 end


local Timer = {
    actions = {},
    tweens = {}
}

Timer.tweens['linear'] = easing.linear
Timer.tweens['in-quad'] = easing.inQuad
Timer.tweens['out-quad'] = easing.outQuad
Timer.tweens['in-out-quad'] = easing.inOutQuad
Timer.tweens['out-in-quad'] = easing.outInQuad

function Timer.new()
    local timer = lume.clone(Timer)
    timer.actions = {}
    return timer
end

function Timer:addAction(action)
    return lume.push(self.actions, action)
end

--- `func` will be executed after `delay` seconds
function Timer:after(delay, func)
    return self:addAction(Action.new(func, function(self, dt)
        Action.update(self, dt)
        if self.elapsed > delay then
            self:trigger()
            self:finish()
        end
    end))
end

-- `func` will be executed every `delay` seconds `count` times.
-- if `count` is nil, the execution will last until `Timer:cancel()` or
-- `Timer:clear()` is called.
function Timer:every(delay, func, count)
    count = count or math.huge
    local step = 1
    return self:addAction(Action.new(func, function(self, dt)
        Action.update(self, dt)
        if step == 1 or self.elapsed > delay then
            self:trigger()
            step = step + 1
            if step > count then self:finish() end
        end
    end))
end

-- `func(dt, elapsed)` will be executed every frame during `delay` seconds.
-- optional `after` function is called after the last `func` execution.
function Timer:during(delay, func, after)
    after = after or function() end
    return self:addAction(Action.new(nil, function(self, dt)
        Action.update(self, dt)
        if self.elapsed < delay then func(dt, self.elapsed)
        else after(after) self:finish() end
    end))
end

function Timer:tween(duration, subject, target, method, after)
    method = method or 'linear'
    if not Timer.tweens[method] then
        error('No tweening method called ' .. method)
    end
    -- memorize beginning values
    local begin = {}
    for k in pairs(target) do begin[k] = subject[k] end

    return self:during(duration, function(_, elapsed)
        for k, v in pairs(target) do
            subject[k] = Timer.tweens[method](elapsed, begin[k], v - begin[k], duration)
        end
    end, after)
end

-- prevents a timer from executing an action in the future
function Timer:cancel(action)
    lume.remove(self.actions, action)
end

-- clears all actions scheduled by the timer.
-- note : non-executed actions will be discarded.
function Timer:clear()
    self.actions = {}
end

-- updates the timer. to be called in `love.update(dt)`.
function Timer:update(dt)
    local finished = {}
    for _, action in ipairs(self.actions) do
        action:update(dt)
        if action:isFinished() then lume.push(finished, action) end
    end
    for _, action in ipairs(finished) do lume.remove(self.actions, action) end
end


return Timer