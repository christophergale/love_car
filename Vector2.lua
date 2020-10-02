Vector2 = { x = 0, y = 0, }
meta = {}

function Vector2:New(vector)
    local vector = vector or {}
    setmetatable(vector, meta)
    meta.__index = self

    return vector
end

function Vector2:Magnitude()
    return math.sqrt(self.x^2 + self.y^2)
end

function Vector2:Normalize()
    return self / self:Magnitude()
end

function Vector2.Add(vector1, vector2)
    return Vector2:New{x = vector1.x + vector2.x, y = vector1.y + vector2.y}
end

function Vector2.Divide(vector, scalar)
    return Vector2:New{
        x = vector.x / scalar,
        y = vector.y / scalar
    }
end

meta.__div = Vector2.Divide

function Vector2.DotProduct(vector1, vector2)
    return ((vector1.x * vector2.x) + (vector1.y * vector2.y))
end

function Vector2.FindAngleCosine(vector1, vector2)
    return Vector2.DotProduct(vector1, vector2) / (vector1:Magnitude() * vector2:Magnitude())
end

function Vector2.FindAngleRadians(vector1, vector2)
    return math.acos(Vector2.FindAngleCosine(vector1, vector2))
end

return Vector2