Dust = require'Dust'
Vector2 = require'Vector2'

Car =
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
    sounds =
    {
        idle_engine = love.audio.newSource('assets/sounds/large/Idle_Engine.wav', 'static'),
        rev_engine_loop = love.audio.newSource('assets/sounds/large/Rev_Loop.wav', 'static'),
        skid_short_01 = love.audio.newSource('assets/sounds/large/Skid_Short.wav', 'static'),
        skid_long = love.audio.newSource('assets/sounds/large/Skid_Long_01.wav', 'static'),
    },
    position = Vector2:New{ x = 400, y = 300 },
    velocity = Vector2:New{x = 0, y = 0},
    rotation = 0,
    acceleration = 40,
    friction = 4,
    maxSpeed = 200,

    skidMarks = {},
    maxSkidMarks = 120,

    dustParticles = {},
    maxDustParticles = 45,

    toMouse = Vector2:New(),
    toMouseNormalized = Vector2:New(),

    mouseButton = 0,
}

function Car:New(initialPosition, mouseButton)
    local car = {}
    car.position = initialPosition
    car.mouseButton = mouseButton
    setmetatable(car, self)
    self.__index = self

    return car
end

function Car:setAudioParameters()
    setSoundParameters(self.sounds.idle_engine, 1.25, nil, true)
    setSoundParameters(self.sounds.rev_engine_loop, nil, 0.5, true)
    setSoundParameters(self.sounds.skid_long, 1.25, 0.75, true)
end

function setSoundParameters(sound, pitch, volume, looping)
    sound:setPitch(pitch or 1)
    sound:setVolume(volume or 1)
    sound:setLooping(looping or false)
end

function Car:setSpriteFilter()
    for i, sprite in ipairs(self.sprites) do
        sprite:setFilter('nearest', 'nearest')
    end
end

function Car:draw()
    for i, sprite in ipairs(self.sprites) do
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sprite, self.position.x, self.position.y - (i * 3), self.rotation, 3, 3, 8, 8)
    end
end

function Car:updatePosition(dt)
    self.position.x = self.position.x + self.velocity.x
    self.position.y = self.position.y + self.velocity.y

    self.velocity.x = self.velocity.x * (1 - math.min(dt * self.friction, 1))
    self.velocity.y = self.velocity.y * (1 - math.min(dt * self.friction, 1))

    self.toMouse = Vector2:New{x = love.mouse.getX() - self.position.x, y = love.mouse.getY() - self.position.y}
    self.toMouseNormalized = self.toMouse:Normalize()

    self.rotation = math.atan2(self.toMouseNormalized.y, self.toMouseNormalized.x)

    if love.mouse.isDown(self.mouseButton) then
        if self.velocity.x < self.maxSpeed and self.toMouse:Magnitude() > 60 then
            self.velocity.x = self.velocity.x + self.toMouseNormalized.x * self.acceleration * dt
            self.velocity.y = self.velocity.y + self.toMouseNormalized.y * self.acceleration * dt
        end

        if self.velocity:Magnitude() < 6 then
            self:burnout()
        else
            love.audio.stop(self.sounds.skid_short_01)
        end

        self:playEngineAudio('rev')
    else
        self:playEngineAudio('idle')
    end

    if math.abs(math.deg(Vector2.FindAngleRadians(self.velocity, self.toMouse))) > 20 and self.velocity:Magnitude() > 4 then
        self:drift()
    else
        love.audio.stop(self.sounds.skid_long)
    end
end

function Car:playEngineAudio(state)
    if state == 'rev' then
        self.sounds.rev_engine_loop:setPitch(math.max(0.75, 0.2 * self.velocity:Magnitude()))
        self.sounds.rev_engine_loop:setVolume(0.075 * self.velocity:Magnitude())
        love.audio.play(self.sounds.rev_engine_loop)
        love.audio.stop(self.sounds.idle_engine)
    elseif state == 'idle' then
        love.audio.play(self.sounds.idle_engine)
        love.audio.stop(self.sounds.skid_short_01)
        love.audio.stop(self.sounds.rev_engine_loop)
    end
end

function Car:addDust()
    table.insert(self.dustParticles, #self.dustParticles + 1, Dust:New{position = Vector2:New{x = self.position.x - self.toMouseNormalized.y * 8, y = self.position.y - -self.toMouseNormalized.x * 8}})
    table.insert(self.dustParticles, #self.dustParticles + 1, Dust:New{position = Vector2:New{x = self.position.x - -self.toMouseNormalized.y * 8, y = self.position.y - self.toMouseNormalized.x * 8}})
end

function Car:updateDust()
    if #self.dustParticles > self.maxDustParticles then
        for i = 1, #self.dustParticles - self.maxDustParticles, 1 do
            table.remove(self.dustParticles, i)
        end
    end

    for i, dust in ipairs(self.dustParticles) do
        dust.position.y = dust.position.y - .6
        dust.scale = dust.scale + .02
        dust.opacity = dust.opacity - .01

        if dust.opacity <= 0 then
            table.remove(self.dustParticles, 1)
        end
    end
end

function Car:drawDust()
    for i, dust in ipairs(self.dustParticles) do
        local initialSize = love.math.random(3, 6)
        love.graphics.setColor(.6, .6, .6, dust.opacity)
        love.graphics.rectangle('fill', dust.position.x, dust.position.y, initialSize * dust.scale, initialSize * dust.scale)
    end
end

function Car:addSkidMarks()
    table.insert(self.skidMarks, #self.skidMarks + 1, Vector2:New{x = self.position.x - self.toMouseNormalized.y * 8, y = self.position.y - -self.toMouseNormalized.x * 8})
    table.insert(self.skidMarks, #self.skidMarks + 1, Vector2:New{x = self.position.x - -self.toMouseNormalized.y * 8, y = self.position.y - self.toMouseNormalized.x * 8})
end

function Car:updateSkidMarks()
    if #self.skidMarks > self.maxSkidMarks then
        for i = 1, #self.skidMarks - self.maxSkidMarks, 1 do
            table.remove(self.skidMarks, i)
        end
    end
end

function Car:drawSkidMarks()
    for i, mark in ipairs(self.skidMarks) do
        love.graphics.setColor(.2, .2, .2)
        love.graphics.rectangle('fill', mark.x, mark.y, 6, 6)
    end
end

function Car:burnout()
    self:addDust()
    self:addSkidMarks()
    self.sounds.skid_short_01:setPitch(love.math.random(1, 1.5))
    self.sounds.skid_short_01:setVolume(0.75, 1.0)
    love.audio.play(self.sounds.skid_short_01)
end

function Car:drift()
    self:addDust()
    self:addSkidMarks()
    love.audio.play(self.sounds.skid_long)
end

return Car