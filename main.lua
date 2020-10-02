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

    dustParticles = {}
    maxDustParticles = 120

    for i, sprite in ipairs(car.sprites) do
        sprite:setFilter('nearest', 'nearest')
    end

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
            table.insert(dustParticles, #dustParticles + 1, Vector2:New{x = car.position.x - 8, y = car.position.y})
            table.insert(dustParticles, #dustParticles + 1, Vector2:New{x = car.position.x + 8, y = car.position.y})
        end
    end

    if math.abs(math.deg(Vector2.FindAngleRadians(car.velocity, carToMouse))) > 30 and car.velocity:Magnitude() > 4 then
        table.insert(dustParticles, #dustParticles + 1, Vector2:New{x = car.position.x - 8, y = car.position.y})
        table.insert(dustParticles, #dustParticles + 1, Vector2:New{x = car.position.x + 8, y = car.position.y})
    end

    if #dustParticles > maxDustParticles then
        for i = 1, #dustParticles - maxDustParticles, 1 do
            table.remove(dustParticles, i)
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(.3, .3, .3, 1)

    love.graphics.setColor(.4, .4, .4)
    love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 15, 15)

    for i, dust in ipairs(dustParticles) do
        love.graphics.setColor(.2, .2, .2)
        love.graphics.rectangle('fill', dust.x, dust.y, 6, 6)
    end

    for i, sprite in ipairs(car.sprites) do
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sprite, car.position.x, car.position.y - (i * 3), car.rotation, 3, 3, 8, 8)
    end
end