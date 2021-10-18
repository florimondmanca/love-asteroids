local lume = require 'lib.lume'

function lume.randomNormal(sigma, mu)
  -- Uses Box-Muller transform
  sigma = sigma or 1
  mu = mu or 0
  return mu + sigma * math.sqrt(-2*math.log(lume.random())) * math.cos(2*math.pi * lume.random())
end

function lume.noise(x, sigma)
  return x * lume.randomNormal(sigma, 1)
end

function lume.loop(x, min, max, offset)
  min = min - (offset or 0)
  max = max + (offset or 0)
  return x < min and max - math.abs(min - x) or (x > max and min + math.abs(max - x) or x)
end

function lume.dict2array(d)
  local t = {}
  for _, v in pairs(d) do t[#t+1] = v end
  return t
end

function lume.bin(t, x)
  for i = 1, #t - 1 do
    if t[i] <= x and x < t[i+1] then return i end
  end
end

function lume.multilerp(t, y, amount)
  assert(#t == #y, 'multilerp: input and output must have the same length (were' .. #t .. ' and ' .. #y .. ')')
  local tmin, tmax = math.min(unpack(t)), math.max(unpack(t))
  amount = lume.clamp(amount, tmin, tmax)
  local i = lume.bin(t, amount)
  return lume.lerp(y[i], y[i+1], (amount - t[i])/(t[i+1] - t[i]))
end

function lume.lengthof(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end
