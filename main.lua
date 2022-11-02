
function love.load()
    screen_width = love.graphics.getWidth()
    screen_height = love.graphics.getHeight()
    
    level = 1
    score = 0
    numAsteroids = 6

    math.randomseed(os.time())

    deg = 90* math.pi/180 --rotate image 90 degrees

    ship = {}
    ship.x = love.graphics.getWidth()/2
    ship.y = love.graphics.getHeight()/2
    ship.stillimage = love.graphics.newImage("astbin/ship/still.png")
    ship.animation = love.graphics.newImage("astbin/ship/move.png")

    ship.anim1 = love.graphics.newQuad(0,0,32,32,ship.animation:getDimensions())
    ship.anim2 = love.graphics.newQuad(32,0,32,32,ship.animation:getDimensions())
    ship.anim3 = love.graphics.newQuad(64,0,32,32,ship.animation:getDimensions())
    ship.moving = false; 

    ship.currAnim = 1
    ship.animSpeed = .1
    ship.animTime = 0
    
    ship.angle = 270
    ship.angleRadians = 0
    ship.turnAmount = 5
    ship.speed = 80
    ship.numLasers = 0
    ship.laserSpeed = 80 * 5

    ship.lasers = {} --array of lasers
    ship.laserimg = love.graphics.newImage("astbin/ship/laser.png")

    asteroids = {} --array of asteroids

    for i = 0,numAsteroids --is actually 4
    do 
        asteroids[i] = {}
        asteroids[i].x = math.random(0,screen_width)
        asteroids[i].y = math.random(0, screen_height)
        asteroids[i].imgnumber = math.random(1,3)
        asteroids[i].img = love.graphics.newImage("astbin/asteroid"..asteroids[i].imgnumber..".png") --pick random image from 1 to 3
        asteroids[i].rotateLeft = math.random(1,2) == 2
        asteroids[i].moveLeft = math.random(1,2) == 2
        asteroids[i].moveUp = math.random(1,2) == 2
        asteroids[i].radians = 0
        asteroids[i].speed = math.random(20,30)

    end 

    love.window.setTitle("Love Asteroids")

    font = love.graphics.newFont(14)
    love.graphics.setFont(font)

    spaceDown = false
end
   
function love.update(dt)

    processShip(dt)
    processLasers(dt)
    processAsteroids(dt)
end
  
function love.draw()
    drawAsteroids()
    drawShip()
    drawHUD()
end

function drawShip()

    if not ship.moving then
        love.graphics.draw(ship.stillimage, ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

    elseif ship.moving then

        if ship.currAnim == 1 then
            love.graphics.draw(ship.animation, ship.anim1,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        end
        if ship.currAnim == 2 then
            love.graphics.draw(ship.animation, ship.anim2,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        end
        if ship.currAnim == 3 then
            love.graphics.draw(ship.animation, ship.anim3,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        end 
    end

    if ship.numLasers > 0 then

       for i = 1, ship.numLasers
       do
          love.graphics.draw(ship.laserimg, ship.lasers[i].x, ship.lasers[i].y, ship.lasers[i].angleRadians+deg,1,1,ship.laserimg:getWidth()/2,ship.laserimg:getHeight()/2)
       end

    end


end

function processAsteroids(dt)

    for i = 0,numAsteroids
    do
       if asteroids[i].rotateLeft then
          asteroids[i].radians = asteroids[i].radians - 1*dt
       else
          asteroids[i].radians = asteroids[i].radians + 1*dt
       end

       if asteroids[i].moveLeft then
         asteroids[i].x = asteroids[i].x - asteroids[i].speed*dt
       else
         asteroids[i].x = asteroids[i].x + asteroids[i].speed*dt
       end

       if asteroids[i].moveUp then
          asteroids[i].y = asteroids[i].y - asteroids[i].speed*dt
       else
          asteroids[i].y = asteroids[i].y + asteroids[i].speed*dt
       end

       width = asteroids[i].img:getWidth()/2
       height = asteroids[i].img:getHeight()/2

       if asteroids[i].x > screen_width+width then
          asteroids[i].x = -width
       end

       if asteroids[i].x < 0-width then
          asteroids[i].x = screen_width+width 
       end

       if asteroids[i].y > screen_height+height then
          asteroids[i].y = -height
       end

       if asteroids[i].y < 0-height then
          asteroids[i].y = screen_height+height
       end  

    end
end

function processLasers(dt)

    if ship.numLasers > 0 then

        for i = 1, ship.numLasers
        do

            vx = math.cos(ship.lasers[i].angleRadians)*ship.laserSpeed
            vy = math.sin(ship.lasers[i].angleRadians)*ship.laserSpeed
        
            ship.lasers[i].x = ship.lasers[i].x  + vx*dt
            ship.lasers[i].y = ship.lasers[i].y + vy*dt

        end
 
     end

end


function processShip(dt)
    if love.keyboard.isDown("left") then
        ship.angle = ship.angle - ship.turnAmount
    end
    
    if love.keyboard.isDown("right") then
        ship.angle = ship.angle + ship.turnAmount
    end

    if love.keyboard.isDown("space") and spaceDown == false then --spacebar
    
        ci = ship.numLasers + 1
        print("CI " .. ci)

        ship.lasers[ci] = {}
        ship.lasers[ci].x = ship.x
        ship.lasers[ci].y = ship.y
        ship.lasers[ci].angleRadians = ship.angleRadians --impart x,y,radians to laser img 

        ship.numLasers = ship.numLasers+1
        spaceDown = true
    end

    if ship.angle > 360 then
        ship.angle=0
    end

    if ship.angle < 0 then
        ship.angle=360
    end

    ship.moving = false

    if love.keyboard.isDown("up") then
        ship.moving = true

        ship.animTime = ship.animTime + dt 

        if ship.animTime > ship.animSpeed then

            ship.currAnim = ship.currAnim + 1

            if ship.currAnim > 3 then
                ship.currAnim = 1
            end

            ship.animTime = 0
        end

    end

    ship.angleRadians = ship.angle * math.pi/180

    if ship.moving then
    
        vx = math.cos(ship.angleRadians)*ship.speed
        vy = math.sin(ship.angleRadians)*ship.speed
    
        ship.x = ship.x + vx*dt
        ship.y = ship.y + vy*dt
    end

end


function drawAsteroids()
    for i = 0,numAsteroids
    do
        love.graphics.draw(asteroids[i].img, asteroids[i].x, asteroids[i].y, asteroids[i].radians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)
    end

end

function drawHUD() --font display info
    love.graphics.print("Level: " .. level, 0, 0)
    love.graphics.print(" Score: " .. score, screen_width-65, 0)
    love.graphics.print("Angle: " .. ship.angle .. " Radians: " .. ship.angleRadians, 0, 25)
end

function love.keyreleased(key)
    if key == "space" then
       spaceDown = false
    end
 end