Dust =
{
    position = Vector2:New(),
    scale = 1,
    opacity = 1
}

function Dust:New(dust)
    local dust = dust or {}
    setmetatable(dust, self)
    self.__index = self

    return dust
end

return Dust