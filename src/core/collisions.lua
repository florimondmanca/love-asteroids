local collisions = {}

function collisions.circleToCircle(a, b)
    return (b.x - a.x)^2 + (b.y - a.y)^2 <= (a.radius + b.radius)^2
end

return collisions
