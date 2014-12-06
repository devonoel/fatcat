function love.load()
  player = {
    points = 0,
    x = 256,
    y = 256,
    speed = 200
  }

  bird = {
    sprites = {
      up = love.graphics.newImage("bird-up.png"),
      down = love.graphics.newImage("bird-down.png"),
      left = love.graphics.newImage("bird-left.png"),
      right = love.graphics.newImage("bird-right.png")
    },
    x = love.math.random(100, love.graphics.getWidth() - 100),
    y = love.math.random(100, love.graphics.getHeight() - 100),
    time = 0,
    killed = false,

    -- Where the bird is facing
    -- Directions:
    -- 0 = top
    -- 1 = right
    -- 2 = bottom
    -- 3 = left
    direction = 0
  }

  spawn = {
    triggered = false,
    timer = 0
  }

  alarm = {
    sprite = love.graphics.newImage("alarm.png"),
    triggered = false,
    timer = 0
  }


  font = love.graphics.newFont(36)
end

function love.draw()
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(125, 189, 131)
  love.graphics.print(player.points, 50, 730)

  -- Player
  love.graphics.rectangle("fill", player.x, player.y, 32, 32)

  -- Bird
  if bird.direction == 0 then
    love.graphics.draw(bird.sprites.up, bird.x, bird.y)
  elseif bird.direction == 1 then
    love.graphics.draw(bird.sprites.right, bird.x, bird.y)
  elseif bird.direction == 2 then
    love.graphics.draw(bird.sprites.down, bird.x, bird.y)
  elseif bird.direction == 3 then
    love.graphics.draw(bird.sprites.left, bird.x, bird.y)
  end

  if alarm.triggered == true then
    love.graphics.draw(alarm.sprite, bird.x + 8, bird.y - 40)
  end
end

function love.update(dt)
  if love.keyboard.isDown("left") then
    player.x = player.x - (player.speed * dt)
  elseif love.keyboard.isDown("right") then
    player.x = player.x + (player.speed * dt)
  end

  if love.keyboard.isDown("up") then
    player.y = player.y - (player.speed * dt)
  elseif love.keyboard.isDown("down") then
    player.y = player.y + (player.speed * dt)
  end

  birdWatch()

  birdTurn(dt)

  birdKill()

  spawned(dt)

  alarmed(dt)
end

function birdTurn(dt)
  if alarm.triggered == true then
    return
  end

  bird.time = bird.time + dt

  if bird.time > 2 then
    bird.time = 0
    bird.direction = love.math.random(0,3)
  end
end

function birdWatch()
  if bird.killed == true then
    return
  end

  if love.keyboard.isDown("up", "right", "down", "left") then
    -- Looking up
    if bird.direction == 0 and player.y + 60 < bird.y then
      alarm.triggered = true
    end

    -- Looking right
    if bird.direction == 1 and player.x - 60 > bird.x then
      alarm.triggered = true
    end

    -- Looking down
    if bird.direction == 2 and player.y - 60 > bird.y then
      alarm.triggered = true
    end

    -- Looking left
    if bird.direction == 3 and player.x + 60 < bird.x then
      alarm.triggered = true
    end
  end
end

function birdKill()
  if player.x >= bird.x - 32 and player.x <= bird.x + 32  then
    if player.y >= bird.y - 32 and player.y <= bird.y + 56  then
      bird.killed = true
      score()
    end
  end
end

function score()
  bird.x = 200000
  player.points = player.points + 1
  spawn.triggered = true
end

function spawned(dt)
  if spawn.triggered == true then
    spawn.timer = spawn.timer + dt
    if spawn.timer >= 3 then
      spawn.triggered = false
      spawn.timer = 0
      bird.x = love.math.random(100, love.graphics.getWidth() - 100)
      bird.y = love.math.random(100, love.graphics.getHeight() - 100)
      bird.killed = false
    end
  end
end

function alarmed(dt)
  if alarm.triggered == true then
    alarm.timer = alarm.timer + dt
    if alarm.timer >= 1 then
      lose()
    end
  end
end

function lose()
  bird.x = 200000
  player.points = 0
end
