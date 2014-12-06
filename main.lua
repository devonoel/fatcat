function love.load()
  player = {
    points = 0,
    x = 256,
    y = 256,
    speed = 200
  }

  bird = {
    x = love.math.random(100, love.graphics.getWidth() - 100),
    y = love.math.random(100, love.graphics.getHeight() - 100),
    time = 0,

    -- Where the bird is facing
    -- Directions:
    -- 0 = top
    -- 1 = right
    -- 2 = bottom
    -- 3 = left
    direction = 0
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
  if bird.direction == 0 or bird.direction == 2 then
    love.graphics.rectangle("fill", bird.x, bird.y, 16, 32)
  elseif bird.direction == 1 or bird.direction == 3 then
    love.graphics.rectangle("fill", bird.x, bird.y, 32, 16)
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
end

function birdTurn(dt)
  bird.time = bird.time + dt

  if bird.time > 2 then
    bird.time = 0
    bird.direction = love.math.random(0,3)
  end
end

function birdWatch()
  if love.keyboard.isDown("up", "right", "down", "left") then
    -- Looking up
    if bird.direction == 0 and player.y < bird.y then
      lose()
    end

    -- Looking right
    if bird.direction == 1 and player.x > bird.y then
      lose()
    end

    -- Looking down
    if bird.direction == 2 and player.y > bird.y then
      lose()
    end

    -- Looking left
    if bird.direction == 3 and player.x < bird.y then
      lose()
    end
  end

  function birdKill()
    if player.x >= bird.x - 32 and player.x <= bird.x + 32  then
      if player.y >= bird.y - 32 and player.y <= bird.y + 32  then
        score()
      end
    end
  end

  function score()
    bird.x = 200000
    player.points = player.points + 1
  end

  function lose()
    bird.x = 200000
    player.points = 0
  end
end
