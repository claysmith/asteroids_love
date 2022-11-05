require "collision"

function drawRed()
    love.graphics.setColor(1, 0, 0)
end 

function drawGreen()
    love.graphics.setColor(0,1,0)
end

function drawNormal()
    love.graphics.setColor(1, 1, 1)
end 


function love.load()
    screen_width = love.graphics.getWidth()
    screen_height = love.graphics.getHeight()
    laserOnScreen = false
    
    level = 1
    score = 0
    numAsteroids = 6

    math.randomseed(os.time())

    deg = 90* math.pi/180 --rotate ship image 90 degrees

    ship = {}
    ship.x = love.graphics.getWidth()/2
    ship.y = love.graphics.getHeight()/2
    ship.stillimage = love.graphics.newImage("astbin/ship/still.png")
    ship.animation = love.graphics.newImage("astbin/ship/move.png")

    ship.anim1 = love.graphics.newQuad(0,0,32,32,ship.animation:getDimensions())
    ship.anim2 = love.graphics.newQuad(32,0,32,32,ship.animation:getDimensions())
    ship.anim3 = love.graphics.newQuad(64,0,32,32,ship.animation:getDimensions())

    anim = {} --common animations shared by ship and asteroid
    anim.explode = {}

    anim.explode[0] = {}
    anim.explode[0].fullanim = love.graphics.newImage("astbin/ship/explosion.png")
    anim.explode[0].anim1 = love.graphics.newQuad(0,0,32,32,anim.explode[0].fullanim:getDimensions())
    anim.explode[0].anim2 = love.graphics.newQuad(32,0,32,32,anim.explode[0].fullanim:getDimensions())
    anim.explode[0].anim3 = love.graphics.newQuad(64,0,32,32,anim.explode[0].fullanim:getDimensions())
    anim.explode[0].anim4 = love.graphics.newQuad(96,0,32,32,anim.explode[0].fullanim:getDimensions())
    anim.explode[0].anim5 = love.graphics.newQuad(128,0,32,32,anim.explode[0].fullanim:getDimensions())
    anim.explode[0].anim6 = love.graphics.newQuad(160,0,32,32,anim.explode[0].fullanim:getDimensions())
    anim.explode[0].anim7 = love.graphics.newQuad(192,0,32,32,anim.explode[0].fullanim:getDimensions())
    anim.explode[0].animSpeed = .1

    anim.explode[1] = {}
    anim.explode[1].fullanim = love.graphics.newImage("astbin/ship/explosion2.png")
    anim.explode[1].anim1 = love.graphics.newQuad(0,0,32,32,anim.explode[1].fullanim:getDimensions())
    anim.explode[1].anim2 = love.graphics.newQuad(32,0,32,32,anim.explode[1].fullanim:getDimensions())
    anim.explode[1].anim3 = love.graphics.newQuad(64,0,32,32,anim.explode[1].fullanim:getDimensions())
    anim.explode[1].anim4 = love.graphics.newQuad(96,0,32,32,anim.explode[1].fullanim:getDimensions())
    anim.explode[1].anim5 = love.graphics.newQuad(128,0,32,32,anim.explode[1].fullanim:getDimensions())
    anim.explode[1].anim6 = love.graphics.newQuad(160,0,32,32,anim.explode[1].fullanim:getDimensions())
    anim.explode[1].anim7 = love.graphics.newQuad(192,0,32,32,anim.explode[1].fullanim:getDimensions())
    anim.explode[1].animSpeed = .1

    ship.explodeAnimTime = 0


    ship.explodeAnimNdx = math.random(0,1)
    ship.moving = false; 
    ship.halfWidth = ship.stillimage:getWidth()/2 --is 16 here for both
    ship.halfHeight = ship.stillimage:getHeight()/2
    ship.w = ship.stillimage:getWidth()
    ship.h = ship.stillimage:getHeight()

    --print("ship half width and height (" .. ship.halfWidth .. " " .. ship.halfHeight .. ")")

    ship.explodeAnim = 1 --keeps track of explode anim index

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
        asteroids[i].headingAngle = math.random(0,360) --asteroid picks random angle and moves along it
        asteroids[i].headingRadians = asteroids[i].headingAngle * math.pi/180
        asteroids[i].radians = 0
        asteroids[i].speed = math.random(20,30)
        
        asteroids[i].halfWidth = asteroids[i].img:getWidth()/2
        asteroids[i].halfHeight = asteroids[i].img:getHeight()/2

        asteroids[i].w = asteroids[i].img:getWidth()
        asteroids[i].h = asteroids[i].img:getHeight()

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


    if ship.dead then --draw explosion

        if ship.explodeAnim == 1 then
            love.graphics.draw(anim.explode[ship.explodeAnimNdx].fullanim, anim.explode[ship.explodeAnimNdx].anim1,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 2 then
            love.graphics.draw(anim.explode[ship.explodeAnimNdx].fullanim, anim.explode[ship.explodeAnimNdx].anim2,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 3 then
            love.graphics.draw(anim.explode[ship.explodeAnimNdx].fullanim, anim.explode[ship.explodeAnimNdx].anim3,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 4 then
            love.graphics.draw(anim.explode[ship.explodeAnimNdx].fullanim, anim.explode[ship.explodeAnimNdx].anim4,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 5 then
            love.graphics.draw(anim.explode[ship.explodeAnimNdx].fullanim, anim.explode[ship.explodeAnimNdx].anim5,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 6 then
            love.graphics.draw(anim.explode[ship.explodeAnimNdx].fullanim, anim.explode[ship.explodeAnimNdx].anim6,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 7 then
            love.graphics.draw(anim.explode[ship.explodeAnimNdx].fullanim, anim.explode[ship.explodeAnimNdx].anim7,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)
        end

    else
        --process ship normally
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
        
            love.graphics.rectangle("line", ship.lasers[i].x-ship.lasers[i].halfWidth, ship.lasers[i].y-ship.lasers[i].halfHeight, ship.lasers[i].w, ship.lasers[i].h)

        end

        end
    end




end

function wrapObjectToScreen(object)

    if object.x > screen_width+object.halfWidth then
        object.x = -object.halfWidth
     end

     if object.x < 0-object.halfWidth then
        object.x = screen_width+object.halfWidth
     end

     if object.y > screen_height+object.halfHeight then
        object.y = -object.halfHeight
     end

     if object.y < 0-object.halfHeight then
        object.y = screen_height+object.halfHeight
     end 
end


function processAsteroids(dt)

    ship.collided=false
    for i = 0,numAsteroids
    do
       if asteroids[i].rotateLeft then
          asteroids[i].radians = asteroids[i].radians - 1*dt
       else
          asteroids[i].radians = asteroids[i].radians + 1*dt
       end

       vx = math.cos(asteroids[i].headingRadians)*asteroids[i].speed
       vy = math.sin(asteroids[i].headingRadians)*asteroids[i].speed
   
       asteroids[i].x = asteroids[i].x  + vx*dt
       asteroids[i].y = asteroids[i].y + vy*dt

       wrapObjectToScreen(asteroids[i])

       if boxBoxCollision(ship.x-ship.halfWidth, ship.y-ship.halfHeight,ship.w,ship.h,asteroids[i].x-asteroids[i].halfWidth,asteroids[i].y-asteroids[i].halfHeight,asteroids[i].w,asteroids[i].h) then
          ship.collided=true
          ship.dead=true
       end

    end
end

function processLasers(dt)
    laserOnScreen = false

    if ship.numLasers > 0 then

        for i = 1, ship.numLasers
        do

            vx = math.cos(ship.lasers[i].angleRadians)*ship.laserSpeed
            vy = math.sin(ship.lasers[i].angleRadians)*ship.laserSpeed
        
            ship.lasers[i].x = ship.lasers[i].x  + vx*dt
            ship.lasers[i].y = ship.lasers[i].y + vy*dt

            if boxBoxCollision(ship.lasers[i].x-ship.lasers[i].halfWidth, ship.lasers[i].y-ship.lasers[i].halfHeight, ship.lasers[i].w, ship.lasers[i].h,0,0,screen_width,screen_height) then
                laserOnScreen = true
            end

        end
 
     end

end


function processShip(dt)

    if ship.dead then --just show explosion

        ship.explodeAnimTime = ship.explodeAnimTime + dt

        if ship.explodeAnimTime > anim.explode[ship.explodeAnimNdx].animSpeed then

            ship.explodeAnim = ship.explodeAnim + 1

            ship.explodeAnimTime = 0
        end

    else
        if love.keyboard.isDown("left") then
            ship.angle = ship.angle - ship.turnAmount
        end
        
        if love.keyboard.isDown("right") then
            ship.angle = ship.angle + ship.turnAmount
        end
    
        --FIRE LASERS
        if love.keyboard.isDown("space") and spaceDown == false then --spacebar
        
            if laserOnScreen == false then
                ship.numLasers=0
            end
    
            ci = ship.numLasers + 1
            print("CI " .. ci)
    
            ship.lasers[ci] = {}
            ship.lasers[ci].x = ship.x
            ship.lasers[ci].y = ship.y
            ship.lasers[ci].angleRadians = ship.angleRadians --impart x,y,radians to laser img 
            ship.lasers[ci].w = ship.laserimg:getWidth()
            ship.lasers[ci].h = ship.laserimg:getHeight()
            ship.lasers[ci].halfWidth = ship.lasers[ci].w/2
            ship.lasers[ci].halfHeight = ship.lasers[ci].h/2
    
    
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
    
        --ship.collided = false
    
        if ship.moving then
        
            vx = math.cos(ship.angleRadians)*ship.speed
            vy = math.sin(ship.angleRadians)*ship.speed
        
            ship.x = ship.x + vx*dt
            ship.y = ship.y + vy*dt
    
            wrapObjectToScreen(ship)
    
    
        end
    end

end


function drawAsteroids()
    for i = 0,numAsteroids
    do
        love.graphics.draw(asteroids[i].img, asteroids[i].x, asteroids[i].y, asteroids[i].radians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)
    
        love.graphics.rectangle("line", asteroids[i].x-asteroids[i].halfWidth, asteroids[i].y-asteroids[i].halfHeight, asteroids[i].w, asteroids[i].h)

    end

end

function drawHUD() --font display info
    love.graphics.print("Level: " .. level, 0, 0)
    love.graphics.print(" Score: " .. score, screen_width-65, 0)
    --love.graphics.print("Angle: " .. ship.angle .. " Radians: " .. ship.angleRadians, 0, 25)
end

function love.keyreleased(key)
    if key == "space" then
       spaceDown = false
    end
 end