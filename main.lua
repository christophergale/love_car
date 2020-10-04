Vector2 = require'Vector2'

function love.load()
    car =
    {
        sprites =
        {
            love.graphics.newImage("assets/car/01.png"),
            love.graphics.newImage("assets/car/02.png"),
            love.graphics.newImage("assets/car/03.png"),
            love.graphics.newImage("assets/car/04.png"),
            love.graphics.newImage("assets/car/05.png"),
            love.graphics.newImage("assets/car/06.png"),
            love.graphics.newImage("assets/car/07.png"),
        },
        position = Vector2:New{ x = 400, y = 300 },
        velocity = Vector2:New{x = 0, y = 0},
        rotation = 0,
        acceleration = 40,
        friction = 4,
        maxSpeed = 200
    }

    for i, sprite in ipairs(car.sprites) do
        sprite:setFilter('nearest', 'nearest')
    end

    skidMarks = {}
    maxSkidMarks = 120

    dustParticles = {}
    maxDustParticles = 60

    love.mouse.setVisible(false)
end

function love.update(dt)
    car.position.x = car.position.x + car.velocity.x
    car.position.y = car.position.y + car.velocity.y

    car.velocity.x = car.velocity.x * (1 - math.min(dt * car.friction, 1))
    car.velocity.y = car.velocity.y * (1 - math.min(dt * car.friction, 1))

    carToMouse = Vector2:New{x = love.mouse.getX() - car.position.x, y = love.mouse.getY() - car.position.y}
    carToMouseNormalized = carToMouse:Normalize()

    car.rotation = math.atan2(carToMouseNormalized.y, carToMouseNormalized.x)

    if love.mouse.isDown(1) and car.velocity.x < car.maxSpeed and carToMouse:Magnitude() > 60 then
        car.velocity.x = car.velocity.x + carToMouseNormalized.x * car.acceleration * dt
        car.velocity.y = car.velocity.y + carToMouseNormalized.y * car.acceleration * dt

        if car.velocity:Magnitude() < 6 then
            addSkidMarks()
            addDust()
        end
    end

    if math.abs(math.deg(Vector2.FindAngleRadians(car.velocity, carToMouse))) > 20 and car.velocity:Magnitude() > 4 then
        addSkidMarks()
        addDust()
    end

    if #skidMarks > maxSkidMarks then
        for i = 1, #skidMarks - maxSkidMarks, 1 do
            table.remove(skidMarks, i)
        end
    end

    if #dustParticles > maxDustParticles then
        for i = 1, #dustParticles - maxDustParticles, 1 do
            table.remove(dustParticles, i)
        end
    end

    for i, dust in ipairs(dustParticles) do
        dust.position.y = dust.position.y - .6
        dust.scale = dust.scale + .02
        dust.opacity = dust.opacity - .01

        if dust.opacity <= 0 then
            table.remove(dustParticles, 1)
        end
    end
end

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

function addDust()
    table.insert(dustParticles, #dustParticles + 1, Dust:New{position = Vector2:New{x = car.position.x - carToMouseNormalized.y * 8, y = car.position.y - -carToMouseNormalized.x * 8}})
    table.insert(dustParticles, #dustParticles + 1, Dust:New{position = Vector2:New{x = car.position.x - -carToMouseNormalized.y * 8, y = car.position.y - carToMouseNormalized.x * 8}})
end

function addSkidMarks()
    table.insert(skidMarks, #skidMarks + 1, Vector2:New{x = car.position.x - carToMouseNormalized.y * 8, y = car.position.y - -carToMouseNormalized.x * 8})
    table.insert(skidMarks, #skidMarks + 1, Vector2:New{x = car.position.x - -carToMouseNormalized.y * 8, y = car.position.y - carToMouseNormalized.x * 8})
end

function love.draw()
    love.graphics.setBackgroundColor(.3, .3, .3, 1)

    love.graphics.setColor(.4, .4, .4)
    love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 15, 15)

    for i, mark in ipairs(skidMarks) do
        love.graphics.setColor(.2, .2, .2)
        love.graphics.rectangle('fill', mark.x, mark.y, 6, 6)
    end

    for i, dust in ipairs(dustParticles) do
        local initialSize = love.math.random(3, 6)
        love.graphics.setColor(.6, .6, .6, dust.opacity)
        love.graphics.rectangle('fill', dust.position.x, dust.position.y, initialSize * dust.scale, initialSize * dust.scale)
    end

    for i, sprite in ipairs(car.sprites) do
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sprite, car.position.x, car.position.y - (i * 3), car.rotation, 3, 3, 8, 8)
    end
end