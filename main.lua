function love.load()
  player = {
    points = 0,
    x = 256,
    y = 256,
    speed = 120
  }

  bird = {
    x = love.math.random( 100, love.graphics.getWidth() - 100 ),
    y = love.math.random( 100, love.graphics.getHeight() - 100 )
  }
end

function love.draw()
  love.graphics.setBackgroundColor(125, 189, 131)
  love.graphics.print(player.points, 40, 760)
  love.graphics.rectangle("fill", player.x, player.y, 32, 32)
  love.graphics.rectangle("fill", bird.x, bird.y, 16, 32)
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

  killBird()
end

function killBird()
  if player.x >= bird.x - 32 and player.x <= bird.x + 32  then
    if player.y >= bird.y - 32 and player.y <= bird.y + 32  then
      bird.x = 200000
      player.points = player.points + 1
    end
  end
end
