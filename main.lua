function love.load()
  -- Game state
  -- 0 = Start
  -- 1 = Game
  -- 2 = Loss
  state = 0

  player = {
    sprites = {
      up = love.graphics.newImage("cat-up.png"),
      down = love.graphics.newImage("cat-down.png"),
      left = love.graphics.newImage("cat-left.png"),
      right = love.graphics.newImage("cat-right.png"),

      -- Alt sprites for simple animation
      upAlt = love.graphics.newImage("cat-up-alt.png"),
      downAlt = love.graphics.newImage("cat-down-alt.png"),
      leftAlt = love.graphics.newImage("cat-left-alt.png"),
      rightAlt = love.graphics.newImage("cat-right-alt.png")
    },
    direction = 1,
    moving = false,
    aTimer = 0,
    aRate = 0.3,
    aSwitch = false,
    meals = 0,
    killCountdown = 0,
    fatness = 0.2,
    x = 256,
    y = 256,
    speed = 250
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

  boulders = {
    sprite = love.graphics.newImage("boulder.png"),
    positions = {
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      }
    }
  }

  grass = {
    sprite = love.graphics.newImage("grass.png"),
    positions = {
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      },
      {
        x = love.math.random(150, love.graphics.getWidth() - 150),
        y = love.math.random(150, love.graphics.getHeight() - 150)
      }
    }
  }

  -- Sounds
  deathSound = love.audio.newSource("death.wav", "static")

  -- Fonts
  titleFont = love.graphics.newFont("Montserrat-Bold.ttf", 150)
  startFont = love.graphics.newFont("Montserrat-Bold.ttf", 36)
  arrowFont = love.graphics.newFont("Montserrat-Bold.ttf", 28)
  instructionFont = love.graphics.newFont("Montserrat-Bold.ttf", 26)
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

    love.graphics.setFont(startFont)
    love.graphics.print("Press Space to Start", love.graphics.getWidth()/3 + 10, love.graphics.getHeight()/2)
    love.graphics.setFont(arrowFont)
    love.graphics.print("Arrow Keys to Move, Shift to Run", love.graphics.getWidth()/4 + 60, love.graphics.getHeight()/2 + 50)

    love.graphics.setFont(instructionFont)
    love.graphics.print("Sneak up on birds, eat 'em up, get fat", love.graphics.getWidth()/4 + 50, love.graphics.getHeight()/2 + 130)
    love.graphics.print("The fatter you are, the slower you move", love.graphics.getWidth()/4 + 40, love.graphics.getHeight()/2 + 170)

    love.graphics.setColor(r,g,b,a)
  end

  if state == 1 then
    love.graphics.draw(boulders.sprite, boulders.positions[1].x, boulders.positions[1].y)
    love.graphics.draw(boulders.sprite, boulders.positions[2].x, boulders.positions[2].y)
    love.graphics.draw(boulders.sprite, boulders.positions[3].x, boulders.positions[3].y)

    love.graphics.draw(grass.sprite, grass.positions[1].x, grass.positions[1].y)
    love.graphics.draw(grass.sprite, grass.positions[2].x, grass.positions[2].y)
    love.graphics.draw(grass.sprite, grass.positions[3].x, grass.positions[3].y)
    love.graphics.draw(grass.sprite, grass.positions[4].x, grass.positions[4].y)
    love.graphics.draw(grass.sprite, grass.positions[5].x, grass.positions[5].y)
    love.graphics.draw(grass.sprite, grass.positions[6].x, grass.positions[6].y)
    love.graphics.draw(grass.sprite, grass.positions[7].x, grass.positions[7].y)
    love.graphics.draw(grass.sprite, grass.positions[8].x, grass.positions[8].y)

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
    love.graphics.draw(playerSprite(), player.x, player.y, 0, player.fatness, player.fatness)

    -- Alarm indicators
    if alarm.triggered == true then
      for i=1, birdCount, 1 do
        love.graphics.draw(alarm.sprite, birds[i].x + 6, birds[i].y - 40)
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

    playerAnimateTimer(dt)

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
    alarm.triggered = false
    alarm.timer = 0
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
  if love.keyboard.isDown("rshift", "lshift") then
    activeSpeed = player.speed * 3
    alarm.triggered = true
  else
    activeSpeed = player.speed
  end

  if love.keyboard.isDown("left") then
    player.direction = 3
    player.x = player.x - (activeSpeed * dt)
  elseif love.keyboard.isDown("right") then
    player.direction = 1
    player.x = player.x + (activeSpeed * dt)
  end

  if love.keyboard.isDown("up") then
    player.direction = 0
    player.y = player.y - (activeSpeed * dt)
  elseif love.keyboard.isDown("down") then
    player.direction = 2
    player.y = player.y + (activeSpeed * dt)
  end

  if love.keyboard.isDown("up", "right", "down", "left") then
    player.moving = true
  else
    player.moving = false
  end
end

function wallCollision()
  if player.x < 0 then
    player.x = 0
  elseif player.x > love.graphics.getWidth() - playerWidth() then
    player.x = love.graphics.getWidth() - playerWidth()
  end

  if player.y < 0 then
    player.y = 0
  elseif player.y > love.graphics.getHeight() - playerHeight() then
    player.y = love.graphics.getHeight()  - playerHeight()
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

    if player.x <= birds[i].x + birdWidth and player.x + playerWidth() >= birds[i].x then
      if player.y <= birds[i].y + birdHeight and player.y + playerHeight() >= birds[i].y then
        birds[i].killed = true
        addMeal(i)
      end
    end
  end
end

function addMeal(i)
  birds[i].x = 200000
  deathSound:stop()
  deathSound:play()
  player.meals = player.meals + 1
  player.killCountdown = player.killCountdown + 1
  if player.fatness < 1 then
    player.fatness = player.fatness + 0.05
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
  player.killCountdown = 0
  player.fatness = 0.2

  alarm.triggered = false
  alarm.timer = 0

  birdCount = 0
  birds = {}

  spawn.triggered = true
  spawn.timer = 3

  spawnCountdown(dt)

  state = 1
end

function playerSprite()
  if player.direction == 0 then
    -- return player.sprites.up
    return playerAnimateSwitch(player.sprites.up, player.sprites.upAlt)
  elseif player.direction == 1 then
    -- return player.sprites.right
    return playerAnimateSwitch(player.sprites.right, player.sprites.rightAlt)
  elseif player.direction == 2 then
    -- return player.sprites.down
    return playerAnimateSwitch(player.sprites.down, player.sprites.downAlt)
  elseif player.direction == 3 then
    -- return player.sprites.left
    return playerAnimateSwitch(player.sprites.left, player.sprites.leftAlt)
  end
end

function playerWidth()
  return playerSprite():getWidth() * player.fatness
end

function playerHeight()
  return playerSprite():getHeight() * player.fatness
end

function playerAnimateTimer(dt)
  if player.moving == true then
    player.aTimer = player.aTimer + dt
    if player.aTimer >= player.aRate then
      player.aTimer = 0
      player.aSwitch = not player.aSwitch
    end
  end
end

function playerAnimateSwitch(s1, s2)
  if player.aSwitch == true then
    return s1
  else
    return s2
  end
end
