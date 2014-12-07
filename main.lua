function love.load()
  -- Game state
  -- 0 = Start
  -- 1 = Game
  -- 2 = Loss
  state = 0

  player = {
    meals = 0,
    killCountdown = 0,
    x = 256,
    y = 256,
    width = 32,
    height = 32,
    speed = 200
  }

  birdCount = 0
  vision = {
    minForward = 40,
    maxForward = 300,
    minSide = 0,
    maxSide = 200
  }
  birds = {}

  spawn = {
    triggered = true,
    timer = 3
  }

  alarm = {
    sprite = love.graphics.newImage("alarm.png"),
    triggered = false,
    timer = 0
  }

  -- Sounds
  deathSound = love.audio.newSource("death.wav", "static")

  -- Fonts
  titleFont = love.graphics.newFont("Montserrat-Bold.ttf", 150)
  instructionFont = love.graphics.newFont("Montserrat-Bold.ttf", 36)
  mealsFont = love.graphics.newFont("Montserrat-Bold.ttf", 40)
  caughtFont = love.graphics.newFont("Montserrat-Bold.ttf", 120)
  lossFont = love.graphics.newFont("Montserrat-Bold.ttf", 40)
end

function love.draw()
  love.graphics.setBackgroundColor(125, 189, 131)
  r,g,b,a = love.graphics.getColor()

  if state == 0 then
    love.graphics.setColor(80,80,90)
    love.graphics.setFont(titleFont)
    love.graphics.print("FatCat", love.graphics.getWidth()/4 + 50, love.graphics.getHeight()/3 - 100)
    love.graphics.setFont(instructionFont)
    love.graphics.print("Press Space to Start", love.graphics.getWidth()/3 + 10, love.graphics.getHeight()/2)
    love.graphics.setColor(r,g,b,a)
  end

  if state == 1 then
    love.graphics.setColor(163,227,169)
    love.graphics.setFont(mealsFont)
    love.graphics.print("Snacks: "..player.meals, 50, 710)
    love.graphics.setColor(r,g,b,a)

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

    -- Player
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

    if alarm.triggered == true then
      for i=1, birdCount, 1 do
        love.graphics.draw(alarm.sprite, birds[i].x + 8, birds[i].y - 40)
      end
    end
  end

  if state == 2 then
    love.graphics.setColor(80,80,90)
    love.graphics.setFont(caughtFont)
    love.graphics.print("Caught :(", love.graphics.getWidth()/4 + 10, love.graphics.getHeight()/2 - 150)
    love.graphics.setFont(lossFont)
    love.graphics.print("Total snacks: "..player.meals, love.graphics.getWidth()/4 + 140, love.graphics.getHeight()/2 + 60)
    love.graphics.print("Press Space to Restart", love.graphics.getWidth()/4 + 60, love.graphics.getHeight()/2 + 130)
    love.graphics.setColor(r,g,b,a)
  end
end

function love.update(dt)
  if state == 0 then
    if love.keyboard.isDown(" ") then
      state = 1
    end
  end

  if state == 1 then
    spawnCountdown(dt)

    playerMove(dt)

    wallCollision()

    birdWatch()

    birdTurn(dt)

    birdCollision()

    alarmed(dt)
  end

  if state == 2 then
    if love.keyboard.isDown(" ") then
      restart(dt)
    end
  end
end

function spawnCountdown(dt)
  if spawn.triggered == true then
    spawn.timer = spawn.timer + dt
    if spawn.timer >= 2 then
      birds = {}
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

function wallCollision()
  if player.x < 0 then
    player.x = 0
  elseif player.x > love.graphics.getWidth() - player.width then
    player.x = love.graphics.getWidth() - player.width
  end

  if player.y < 0 then
    player.y = 0
  elseif player.y > love.graphics.getHeight() - player.height then
    player.y = love.graphics.getHeight()  - player.height
  end
end

function birdWatch()
  for i=1, birdCount, 1 do
    if birds[i].killed == true then
      return
    end

    if love.keyboard.isDown("up", "right", "down", "left") then
      -- Looking up
      if birds[i].direction == 0 then
        if checkFront(0, "y", i) then
          if checkSide(0, "x", i) then
            alarm.triggered = true
          elseif checkSide(1, "x", i) then
            alarm.triggered = true
          end
        end
      end

      -- Looking right
      if birds[i].direction == 1 then
        if checkFront(1, "x", i) then
          if checkSide(0, "y", i) then
            alarm.triggered = true
          elseif checkSide(1, "y", i) then
            alarm.triggered = true
          end
        end
      end

      -- Looking down
      if birds[i].direction == 2 then
        if checkFront(1, "y", i) then
          if checkSide(0, "x", i) then
            alarm.triggered = true
          elseif checkSide(1, "x", i) then
            alarm.triggered = true
          end
        end
      end

      -- Looking left
      if birds[i].direction == 3 then
        if checkFront(0, "x", i) then
          if checkSide(0, "y", i) then
            alarm.triggered = true
          elseif checkSide(1, "y", i) then
            alarm.triggered = true
          end
        end
      end
    end
  end
end

-- Vision check at the birds front
-- sign:
  -- 0 indicates moving towards 0
  -- 1 indicates moving towards infinity
-- axis:
  -- x
  -- y
-- i:
  -- index of the bird in the bird table
function checkFront(sign, axis, i)
  if sign == 0 then
    return player[axis] < birds[i][axis] - vision.minForward and player[axis] > birds[i][axis] - vision.maxForward
  elseif sign == 1 then
    return player[axis] > birds[i][axis] + vision.minForward and player[axis] < birds[i][axis] + vision.maxForward
  end
end

-- Vision check at the birds sides
-- side:
  -- 0 indicates moving towards 0
  -- 1 indicates moving towards infinity
-- axis:
  -- x
  -- y
-- i:
  -- index of the bird in the bird table
function checkSide(sign, axis, i)
  if sign == 0 then
    return player[axis] < birds[i][axis] - vision.minSide and player[axis] > birds[i][axis] - vision.maxSide
  elseif sign == 1 then
    return player[axis] > birds[i][axis] + vision.minSide and player[axis] < birds[i][axis] + vision.maxSide
  end
end

function birdTurn(dt)
  if alarm.triggered == true then
    return
  end


  for i=1, birdCount, 1 do
    birds[i].time = birds[i].time + dt

    if birds[i].time > 3 then
      birds[i].time = 0
      birds[i].direction = love.math.random(0,3)
    end
  end
end

function birdCollision()
  for i=1, birdCount, 1 do
    birdWidth = birds[i].sprites.up:getWidth()
    birdHeight = birds[i].sprites.up:getHeight()

    if player.x <= birds[i].x + birdWidth and player.x + player.width >= birds[i].x then
      if player.y <= birds[i].y + birdHeight and player.y + player.height >= birds[i].y then
        birds[i].killed = true
        addMeal(i)
      end
    end
  end
end

function addMeal(i)
  birds[i].x = 200000
  deathSound:play()
  player.meals = player.meals + 1
  player.killCountdown = player.killCountdown + 1
  if player.width < 150 then
    player.width = player.width + 5
    player.height = player.height + 5
  end
  if player.speed > 50 then
    player.speed = player.speed - 5
  end
  if birdCount - player.killCountdown == 0 then
    alarm.triggered = false
    alarm.timer = 0
    player.killCountdown = 0
    spawn.triggered = true
  end
end

function alarmed(dt)
  if alarm.triggered == true then
    alarm.timer = alarm.timer + dt
    if alarm.timer >= 1 then
      loss()
    end
  end
end

function loss()
  state = 2
end

function restart(dt)
  player.meals = 0
  player.speed = 200
  player.width = 32
  player.height = 32
  player.killCountdown = 0

  alarm.triggered = false
  alarm.timer = 0

  birdCount = 0
  birds = {}

  spawn.triggered = true
  spawn.timer = 3

  spawnCountdown(dt)

  state = 1
end
