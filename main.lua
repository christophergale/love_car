Vector2 = require'Vector2'
Car = require'Car'

function love.load()
    cars =
    {
        car01 = Car:New(Vector2:New{x = 50, y = 50}, 1),
    }

    for _, car in pairs(cars) do
        car:setSpriteFilter()
        car:setAudioParameters()
    end

    love.mouse.setVisible(false)
end

function love.update(dt)
    for _, car in pairs(cars) do
        car:updatePosition(dt)
    end

    for _, car in pairs(cars) do
        car:updateSkidMarks()
        car:updateDust()
    end
    

    --[[ if target then
        carToTarget = Vector2:New{x = target.position.x - car01.position.x, y = target.position.y - car01.position.y}:Normalize()
    end ]]
end

function love.draw()
    love.graphics.setBackgroundColor(.3, .3, .3, 1)

    love.graphics.setColor(.4, .4, .4)
    love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 15, 15)

    --[[ if target then
        love.graphics.setColor(.5, .1, .1)
        love.graphics.circle('fill', target.position.x, target.position.y, 30, 30)

        love.graphics.setColor(1,1,1,1)
        love.graphics.print(math.deg(Vector2.FindAngleRadians(target.initialVectorToCar, carToTarget)))
    end ]]

    for _, car in pairs(cars) do
        car:drawSkidMarks()
    end

    for _, car in pairs(cars) do
        car:drawDust()
    end

    for _, car in pairs(cars) do
        car:draw()
    end
end

--[[ function createTarget()
    local width, height = love.graphics.getDimensions()

    target =
    {
        position = Vector2:New{x = love.math.random(120, width - 120), y = love.math.random(120, height - 120)}, 
    }

    target.initialVectorToCar = Vector2:New{x = target.position.x - car01.position.x, y = target.position.y - car01.position.y}
end ]]

--[[ function love.keypressed(key)
    createTarget()
end ]]