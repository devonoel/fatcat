function love.load()
  -- Game state
  -- 0 = Start
  -- 1 = Started
  -- 2 = Lose
  state = 0

  player = {
    meals = 0,
    x = 256,
    y = 256,
    speed = 200
  }

  birdCount = 0
  birds = {}
  killCountdown = 0

  -- bird = {
  --   sprites = {
  --     up = love.graphics.newImage("bird-up.png"),
  --     down = love.graphics.newImage("bird-down.png"),
  --     left = love.graphics.newImage("bird-left.png"),
  --     right = love.graphics.newImage("bird-right.png")
  --   },
  --   x = love.math.random(100, love.graphics.getWidth() - 100),
  --   y = love.math.random(100, love.graphics.getHeight() - 100),
  --   time = 0,
  --   killed = false,
  --
  --   -- Where the bird is facing
  --   -- Directions:
  --   -- 0 = top
  --   -- 1 = right
  --   -- 2 = bottom
  --   -- 3 = left
  --   direction = 0
  -- }

  spawn = {
    triggered = true,
    timer = 3
  }

  alarm = {
    sprite = love.graphics.newImage("alarm.png"),
    triggered = false,
    timer = 0
  }

  startFont = love.graphics.newFont(64)
  mealsFont = love.graphics.newFont(36)
  loseFont = love.graphics.newFont(64)
end

function love.draw()
  love.graphics.setBackgroundColor(125, 189, 131)

  if state == 0 then
    love.graphics.setFont(startFont)
    love.graphics.print("FatCat", love.graphics.getWidth()/3 + 75, love.graphics.getHeight()/2 - 150)
    love.graphics.print("Press Space to Start", love.graphics.getWidth()/4, love.graphics.getHeight()/2 - 50)
  end

  if state == 1 then
    love.graphics.setFont(mealsFont)
    love.graphics.print("Meals: "..player.meals, 50, 730)

    -- Player
    love.graphics.rectangle("fill", player.x, player.y, 32, 32)

    -- Birds
    for i=1, birdCount, 1 do
      if birds[i].direction == 0 then
        love.graphics.draw(birds[i].sprites.up, birds[i].x, birds[i].y)
      elseif birds[i].direction == 1 then
        love.graphics.draw(birds[i].sprites.right, birds[i].x, birds[i].y)
      elseif birds[i].direction == 2 then
        love.graphics.draw(birds[i].sprites.down, birds[i].x, birds[i].y)
      elseif birds[i].direction == 3 then
        love.graphics.draw(birds[i].sprites.left, birds[i].x, birds[i].y)
      end
    end

    if alarm.triggered == true then
      for i=1, birdCount, 1 do
        love.graphics.draw(alarm.sprite, birds[i].x + 8, birds[i].y - 40)
      end
    end
  end

  if state == 2 then
    love.graphics.setFont(startFont)
    love.graphics.print("No more meals :(", love.graphics.getWidth()/4, love.graphics.getHeight()/2 - 150)
    love.graphics.print("Total meals: "..player.meals, love.graphics.getWidth()/4, love.graphics.getHeight()/2 - 50)
    love.graphics.print("Press Space to Restart", love.graphics.getWidth()/4, love.graphics.getHeight()/2 + 50)
  end
end

function love.update(dt)
  if state == 0 then
    if love.keyboard.isDown(" ") then
      state = 1
    end
  end

  if state == 1 then
    spawnTimer(dt)

    playerMove(dt)

    birdWatch()

    birdTurn(dt)

    birdKill()

    alarmed(dt)
  end

  if state == 2 then
    if love.keyboard.isDown(" ") then
      restart(dt)
    end
  end
end

function playerMove(dt)
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
end

function birdTurn(dt)
  if alarm.triggered == true then
    return
  end


  for i=1, birdCount, 1 do
    birds[i].time = birds[i].time + dt

    if birds[i].time > 2 then
      birds[i].time = 0
      birds[i].direction = love.math.random(0,3)
    end
  end
end

function birdWatch()
  for i=1, birdCount, 1 do
    if birds[i].killed == true then
      return
    end

    if love.keyboard.isDown("up", "right", "down", "left") then
      -- Looking up
      if birds[i].direction == 0 and player.y + 60 < birds[i].y then
        alarm.triggered = true
      end

      -- Looking right
      if birds[i].direction == 1 and player.x - 60 > birds[i].x then
        alarm.triggered = true
      end

      -- Looking down
      if birds[i].direction == 2 and player.y - 60 > birds[i].y then
        alarm.triggered = true
      end

      -- Looking left
      if birds[i].direction == 3 and player.x + 60 < birds[i].x then
        alarm.triggered = true
      end
    end
  end
end

function birdKill()
  for i=1, birdCount, 1 do
    if player.x >= birds[i].x - 32 and player.x <= birds[i].x + 32  then
      if player.y >= birds[i].y - 32 and player.y <= birds[i].y + 56  then
        birds[i].killed = true
        addMeal(i)
      end
    end
  end
end

function addMeal(i)
  birds[i].x = 200000
  player.meals = player.meals + 1
  killCountdown = killCountdown + 1
  if birdCount - killCountdown == 0 then
    killCountdown = 0
    spawn.triggered = true
  end
end

function spawnTimer(dt)
  if spawn.triggered == true then
    spawn.timer = spawn.timer + dt
    if spawn.timer >= 3 then
      spawn.triggered = false
      spawn.timer = 0
      birdCount = birdCount + 1
      spawner()
    end
  end
end

function spawner()
  for i=1, birdCount, 1 do
    birds[i] = {
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
      direction = love.math.random(0, 3)
    }
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
  state = 2
end

function restart(dt)
  player.meals = 0
  player.speed = 200

  alarm.triggered = false
  alarm.timer = 0

  birdCount = 0
  birds = {}

  spawn.triggered = true
  spawn.timer = 3

  spawnTimer(dt)

  state = 1
end
