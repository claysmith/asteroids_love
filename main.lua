require "collision"

function drawRed()
    love.graphics.setColor(1, 0, 0)
end 

function drawGreen()
    love.graphics.setColor(0,1,0)
end

function drawBlue()
    love.graphics.setColor(0,0,1)
end

function drawNormal()
    love.graphics.setColor(1, 1, 1)
end 

function setColor(obj,glowValue)
    love.graphics.setColor(love.math.colorFromBytes(obj.r+glowValue, obj.g+glowValue, obj.b+glowValue))
end

function resetGame(levelUp)

    waitTimeNextLevelCount = 0

    ship.collided=false
    ship.dead=false 
    ship.explodeAnim = 1
    ship.explodeAnimNdx = math.random(0,1)
    spaceDown = true --prevent fire laser on reset

    if not levelUp then --player has died starting over from level 1
        level = 1
        score = 0
        numAsteroids = numAsteroidsStart
        initStars()
    elseif levelUp then
        score = score + (50 * level)
        level = level + 1 -- increase level
        numAsteroids = numAsteroids + 4 -- add five more asteroids than previous
    end

    ship.x = love.graphics.getWidth()/2
    ship.y = love.graphics.getHeight()/2

    for i = 1, ship.numLasers
    do
        ship.lasers[i].dead = true
    end

    initAsteroids()
end

function initStars()
    stars = {}
    numStars = math.random(50,300)

    for i = 0, numStars
    do
        stars[i] = {}

        stars[i].x = math.random(0,screen_width)
        stars[i].y = math.random(0,screen_height)
        stars[i].radius = math.random(1,3)
        stars[i].segments = 8
        stars[i].r = math.random(0,255)
        stars[i].g = math.random(0,255)
        stars[i].b = math.random(0,255)
        stars[i].glowValue = math.random(75,100) 
        stars[i].glowStart = stars[i].glowValue
        stars[i].glowDir = -1--math.random(0,1)

        --if stars[i].glowDir == 0 then
        --    stars[i].glowDir = -1
        --elseif stars[i].glowDir == 1 then
        --    stars[i].glowDir = 1
        --end

    end
end

function processStars(dt)

    for i = 0, numStars
    do
        stars[i].glowValue = stars[i].glowValue + stars[i].glowDir
 
        if stars[i].glowDir == -1 then
            if stars[i].glowValue == 0 then
                stars[i].glowDir = 1
            end
        elseif stars[i].glowDir == 1 then
            if stars[i].glowValue == stars[i].glowStart then
                stars[i].glowDir = -1
            end
        end

    end

end

function InitAsteroid(asteroid)
    asteroid.hit = false
    asteroid.x = math.random(0,screen_width)
    asteroid.y = math.random(0, screen_height)
    asteroid.imgnumber = math.random(1,3)
    asteroid.img = love.graphics.newImage("astbin/asteroid"..asteroid.imgnumber..".png") --pick random image from 1 to 3
    asteroid.headingAngle = math.random(0,360) --asteroid picks random angle and moves along it
    asteroid.headingRadians = asteroid.headingAngle * math.pi/180
    asteroid.radians = 0
    asteroid.speed = math.random(20,100)
    
    asteroid.halfWidth = asteroid.img:getWidth()/2
    asteroid.halfHeight = asteroid.img:getHeight()/2

    asteroid.w = asteroid.img:getWidth()
    asteroid.h = asteroid.img:getHeight()

    --asteroids explode animation
    asteroid.explode = {}
    asteroid.explode[0] = {}
    asteroid.explode[0].fullanim = love.graphics.newImage("astbin/ship/explosion.png")
    asteroid.explode[0].anim1 = love.graphics.newQuad(0,0,32,32,asteroid.explode[0].fullanim:getDimensions())
    asteroid.explode[0].anim2 = love.graphics.newQuad(32,0,32,32,asteroid.explode[0].fullanim:getDimensions())
    asteroid.explode[0].anim3 = love.graphics.newQuad(64,0,32,32,asteroid.explode[0].fullanim:getDimensions())
    asteroid.explode[0].anim4 = love.graphics.newQuad(96,0,32,32,asteroid.explode[0].fullanim:getDimensions())
    asteroid.explode[0].anim5 = love.graphics.newQuad(128,0,32,32,asteroid.explode[0].fullanim:getDimensions())
    asteroid.explode[0].anim6 = love.graphics.newQuad(160,0,32,32,asteroid.explode[0].fullanim:getDimensions())
    asteroid.explode[0].anim7 = love.graphics.newQuad(192,0,32,32,asteroid.explode[0].fullanim:getDimensions())
    asteroid.explode[0].animSpeed = .1
    --asteroids[i].explode[0].animDone = false

    asteroid.explode[1] = {}
    asteroid.explode[1].fullanim = love.graphics.newImage("astbin/ship/explosion2.png")
    asteroid.explode[1].anim1 = love.graphics.newQuad(0,0,32,32,asteroid.explode[1].fullanim:getDimensions())
    asteroid.explode[1].anim2 = love.graphics.newQuad(32,0,32,32,asteroid.explode[1].fullanim:getDimensions())
    asteroid.explode[1].anim3 = love.graphics.newQuad(64,0,32,32,asteroid.explode[1].fullanim:getDimensions())
    asteroid.explode[1].anim4 = love.graphics.newQuad(96,0,32,32,asteroid.explode[1].fullanim:getDimensions())
    asteroid.explode[1].anim5 = love.graphics.newQuad(128,0,32,32,asteroid.explode[1].fullanim:getDimensions())
    asteroid.explode[1].anim6 = love.graphics.newQuad(160,0,32,32,asteroid.explode[1].fullanim:getDimensions())
    asteroid.explode[1].anim7 = love.graphics.newQuad(192,0,32,32,asteroid.explode[1].fullanim:getDimensions())
    asteroid.explode[1].animSpeed = .1
    --asteroids[i].explode[1].animDone = false

    asteroid.explodeAnimTime = 0
    asteroid.explodeAnimNdx = math.random(0,1)
    asteroid.explodeAnim = 1
    asteroid.exploding = false

    asteroid.rotateLeft = math.random(1,2) == 2
end

function initAsteroids()
    asteroids = {} --array of asteroids

    for i = 0,numAsteroids 
    do 
        asteroids[i] = {}
        InitAsteroid(asteroids[i])

        --reinit if this asteroids collides with the ship
        while(boxBoxCollision(shipProtectBox.x, shipProtectBox.y,shipProtectBox.w,shipProtectBox.h,asteroids[i].x-asteroids[i].halfWidth,asteroids[i].y-asteroids[i].halfHeight,asteroids[i].w,asteroids[i].h))
        do 
            InitAsteroid(asteroids[i])
        end
    end 

end


function love.load()
    love.window.setMode(1000, 800, {resizable=false, vsync=0, minwidth=400, minheight=300})
    screen_width = love.graphics.getWidth()
    screen_height = love.graphics.getHeight()
    laserOnScreen = false

    laserSound = love.audio.newSource("astbin/ship/laser.wav","static")
    explosionSound = love.audio.newSource("astbin/explosion.wav","static")

    soundOn = false

    numAsteroidsStart = 2

    level = 1
    score = 0
    numAsteroids = numAsteroidsStart
    waitTimeNextLevel = .8
    waitTimeNextLevelCount = 0

    math.randomseed(os.time())

    deg = 90* math.pi/180 --rotate ship image 90 degrees

    shipProtectBox = {}
    shipProtectBox.x = love.graphics.getWidth()/2 - 250/2
    shipProtectBox.y = love.graphics.getHeight()/2 - 250/2
    shipProtectBox.w = 250
    shipProtectBox.h = 250

    ship = {}
    ship.x = love.graphics.getWidth()/2
    ship.y = love.graphics.getHeight()/2
    ship.stillimage = love.graphics.newImage("astbin/ship/still.png")
    ship.animation = love.graphics.newImage("astbin/ship/move.png")

    ship.anim1 = love.graphics.newQuad(0,0,32,32,ship.animation:getDimensions())
    ship.anim2 = love.graphics.newQuad(32,0,32,32,ship.animation:getDimensions())
    ship.anim3 = love.graphics.newQuad(64,0,32,32,ship.animation:getDimensions())

    ship.explode = {}

    ship.explode[0] = {}
    ship.explode[0].fullanim = love.graphics.newImage("astbin/ship/explosion.png")
    ship.explode[0].anim1 = love.graphics.newQuad(0,0,32,32,ship.explode[0].fullanim:getDimensions())
    ship.explode[0].anim2 = love.graphics.newQuad(32,0,32,32,ship.explode[0].fullanim:getDimensions())
    ship.explode[0].anim3 = love.graphics.newQuad(64,0,32,32,ship.explode[0].fullanim:getDimensions())
    ship.explode[0].anim4 = love.graphics.newQuad(96,0,32,32,ship.explode[0].fullanim:getDimensions())
    ship.explode[0].anim5 = love.graphics.newQuad(128,0,32,32,ship.explode[0].fullanim:getDimensions())
    ship.explode[0].anim6 = love.graphics.newQuad(160,0,32,32,ship.explode[0].fullanim:getDimensions())
    ship.explode[0].anim7 = love.graphics.newQuad(192,0,32,32,ship.explode[0].fullanim:getDimensions())
    ship.explode[0].animSpeed = .1
    --ship.explode[0].animDone = false

    ship.explode[1] = {}
    ship.explode[1].fullanim = love.graphics.newImage("astbin/ship/explosion2.png")
    ship.explode[1].anim1 = love.graphics.newQuad(0,0,32,32,ship.explode[1].fullanim:getDimensions())
    ship.explode[1].anim2 = love.graphics.newQuad(32,0,32,32,ship.explode[1].fullanim:getDimensions())
    ship.explode[1].anim3 = love.graphics.newQuad(64,0,32,32,ship.explode[1].fullanim:getDimensions())
    ship.explode[1].anim4 = love.graphics.newQuad(96,0,32,32,ship.explode[1].fullanim:getDimensions())
    ship.explode[1].anim5 = love.graphics.newQuad(128,0,32,32,ship.explode[1].fullanim:getDimensions())
    ship.explode[1].anim6 = love.graphics.newQuad(160,0,32,32,ship.explode[1].fullanim:getDimensions())
    ship.explode[1].anim7 = love.graphics.newQuad(192,0,32,32,ship.explode[1].fullanim:getDimensions())
    ship.explode[1].animSpeed = .1
    --ship.explode[1].animDone = false

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
    ship.turnAmount = 300
    ship.speed = 80
    ship.numLasers = 0
    ship.laserSpeed = 80 * 5

    ship.lasers = {} --array of lasers
    ship.laserimg = love.graphics.newImage("astbin/ship/laser.png")

    initAsteroids() 
    initStars()

    love.window.setTitle("Love Asteroids")

    font = love.graphics.newFont(14)
    love.graphics.setFont(font)

    spaceDown = false
    sDown = false
    pDown = false 
    paused = false
end


   
function love.update(dt)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    if love.keyboard.isDown("s") and sDown == false then
        soundOn = not soundOn
        sDown = true 
    end

    if love.keyboard.isDown("p") and pDown == false then
        paused = not paused
        pDown = true
    end

    if not paused then
        processStars(dt)
        processShip(dt)
        processLasers(dt)
        processAsteroids(dt)
    end

end
  
function love.draw()
    drawStars()
    drawAsteroids()
    drawShip()
    drawHUD()
end

function drawShip()


    if ship.dead then --draw explosion

        if ship.explodeAnim == 1 then
            love.graphics.draw(ship.explode[ship.explodeAnimNdx].fullanim, ship.explode[ship.explodeAnimNdx].anim1,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)
            
            if soundOn then
                explosionSound:stop()
                explosionSound:play()
            end
        elseif ship.explodeAnim == 2 then
            love.graphics.draw(ship.explode[ship.explodeAnimNdx].fullanim, ship.explode[ship.explodeAnimNdx].anim2,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 3 then
            love.graphics.draw(ship.explode[ship.explodeAnimNdx].fullanim, ship.explode[ship.explodeAnimNdx].anim3,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 4 then
            love.graphics.draw(ship.explode[ship.explodeAnimNdx].fullanim, ship.explode[ship.explodeAnimNdx].anim4,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 5 then
            love.graphics.draw(ship.explode[ship.explodeAnimNdx].fullanim, ship.explode[ship.explodeAnimNdx].anim5,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 6 then
            love.graphics.draw(ship.explode[ship.explodeAnimNdx].fullanim, ship.explode[ship.explodeAnimNdx].anim6,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        elseif ship.explodeAnim == 7 then
            love.graphics.draw(ship.explode[ship.explodeAnimNdx].fullanim, ship.explode[ship.explodeAnimNdx].anim7,ship.x, ship.y, ship.angleRadians+deg,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)
            --ship.explode[ship.explodeAnimNdx].animDone = true
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
            if not ship.lasers[i].dead then
                love.graphics.draw(ship.laserimg, ship.lasers[i].x, ship.lasers[i].y, ship.lasers[i].angleRadians+deg,1,1,ship.laserimg:getWidth()/2,ship.laserimg:getHeight()/2)
            end
        
            --love.graphics.rectangle("line", ship.lasers[i].x-ship.lasers[i].halfWidth, ship.lasers[i].y-ship.lasers[i].halfHeight, ship.lasers[i].w, ship.lasers[i].h)

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
    numHit = 0
    exploding = false 

    for i = 0,numAsteroids
    do

        if asteroids[i].hit then
            asteroids[i].explodeAnimTime = asteroids[i].explodeAnimTime + dt

            if asteroids[i].explodeAnimTime > asteroids[i].explode[asteroids[i].explodeAnimNdx].animSpeed then
    
                asteroids[i].explodeAnim = asteroids[i].explodeAnim + 1
    
                asteroids[i].explodeAnimTime = 0
            end

            numHit = numHit + 1
        else
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

        if asteroids[i].exploding then
            exploding = true
        end

    end

    --increase level
    if numHit == numAsteroids+1 then -- all asteroids have been hit and none are exploding
        
        waitTimeNextLevelCount = waitTimeNextLevelCount+dt
        
        if waitTimeNextLevelCount > waitTimeNextLevel then --wait for last explosion  
            resetGame(true)
        end


    end

end

function processLasers(dt)
    laserOnScreen = false

    if ship.numLasers > 0 then

        for i = 1, ship.numLasers
        do
            if not ship.lasers[i].dead then
                vx = math.cos(ship.lasers[i].angleRadians)*ship.laserSpeed
                vy = math.sin(ship.lasers[i].angleRadians)*ship.laserSpeed
            
                ship.lasers[i].x = ship.lasers[i].x  + vx*dt
                ship.lasers[i].y = ship.lasers[i].y + vy*dt
    
                --see if lasers are on screen
                if boxBoxCollision(ship.lasers[i].x-ship.lasers[i].halfWidth, ship.lasers[i].y-ship.lasers[i].halfHeight, ship.lasers[i].w, ship.lasers[i].h,0,0,screen_width,screen_height) and not ship.lasers[i].dead then
                    laserOnScreen = true
                end
    
    
                for j = 0,numAsteroids
                do
                    --if laser collided with an asteroid
                    if boxBoxCollision(ship.lasers[i].x-ship.lasers[i].halfWidth,ship.lasers[i].y-ship.lasers[i].halfHeight,ship.lasers[i].w,ship.lasers[i].h,asteroids[j].x-asteroids[j].halfWidth,asteroids[j].y-asteroids[j].halfHeight,asteroids[j].w,asteroids[j].h) and not asteroids[j].dead and not asteroids[j].exploding then--and asteroids[j].explode[asteroids[j].explodeAnimNdx].animDone == false then
                        asteroids[j].hit = true
                        ship.lasers[i].dead = true
                        score = score + 5

                        if soundOn then
                            explosionSound:stop()
                            explosionSound:play()
                        end

                    end
                end
    
            end
        end


 
     end

end

function processShip(dt)

    if ship.dead then --just show explosion

        ship.explodeAnimTime = ship.explodeAnimTime + dt

        if ship.explodeAnimTime > ship.explode[ship.explodeAnimNdx].animSpeed then
            --xplosionSound:stop()
            ship.explodeAnim = ship.explodeAnim + 1

            ship.explodeAnimTime = 0
        end

        if love.keyboard.isDown("return", "kpenter") then
            resetGame(false)
        end

    else
        if love.keyboard.isDown("left") then
            ship.angle = ship.angle - ship.turnAmount*dt
        end
        
        if love.keyboard.isDown("right") then
            ship.angle = ship.angle + ship.turnAmount*dt
        end
    
        --FIRE LASERS
        if love.keyboard.isDown("space") and spaceDown == false then --spacebar
        
            --sfx
            if soundOn then
                laserSound:stop()
                laserSound:play()
            end

            if laserOnScreen == false then
                ship.numLasers=0
            end
    
            ci = ship.numLasers + 1
    
            ship.lasers[ci] = {}
            ship.lasers[ci].x = ship.x
            ship.lasers[ci].y = ship.y
            ship.lasers[ci].angleRadians = ship.angleRadians --impart x,y,radians to laser img 
            ship.lasers[ci].w = ship.laserimg:getWidth()
            ship.lasers[ci].h = ship.laserimg:getHeight()
            ship.lasers[ci].halfWidth = ship.lasers[ci].w/2
            ship.lasers[ci].halfHeight = ship.lasers[ci].h/2
            ship.lasers[ci].dead = false
    
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

        if asteroids[i].hit then

            if asteroids[i].explodeAnim == 1 then
                asteroids[i].exploding = true 
                love.graphics.draw(asteroids[i].explode[asteroids[i].explodeAnimNdx].fullanim, asteroids[i].explode[ship.explodeAnimNdx].anim1,asteroids[i].x, asteroids[i].y, asteroids[i].angleRadians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)
    
            elseif asteroids[i].explodeAnim == 2 then
                love.graphics.draw(asteroids[i].explode[asteroids[i].explodeAnimNdx].fullanim, asteroids[i].explode[ship.explodeAnimNdx].anim2,asteroids[i].x, asteroids[i].y, asteroids[i].angleRadians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)

            elseif asteroids[i].explodeAnim == 3 then
                love.graphics.draw(asteroids[i].explode[asteroids[i].explodeAnimNdx].fullanim, asteroids[i].explode[ship.explodeAnimNdx].anim3,asteroids[i].x, asteroids[i].y, asteroids[i].angleRadians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)

            elseif asteroids[i].explodeAnim == 4 then
                love.graphics.draw(asteroids[i].explode[asteroids[i].explodeAnimNdx].fullanim, asteroids[i].explode[ship.explodeAnimNdx].anim4,asteroids[i].x, asteroids[i].y, asteroids[i].angleRadians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)

            elseif asteroids[i].explodeAnim == 5 then
                love.graphics.draw(asteroids[i].explode[asteroids[i].explodeAnimNdx].fullanim, asteroids[i].explode[ship.explodeAnimNdx].anim5,asteroids[i].x, asteroids[i].y, asteroids[i].angleRadians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)

            elseif asteroids[i].explodeAnim == 6 then
                love.graphics.draw(asteroids[i].explode[asteroids[i].explodeAnimNdx].fullanim, asteroids[i].explode[ship.explodeAnimNdx].anim6,asteroids[i].x, asteroids[i].y, asteroids[i].angleRadians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)

            elseif asteroids[i].explodeAnim == 7 then
                love.graphics.draw(asteroids[i].explode[asteroids[i].explodeAnimNdx].fullanim, asteroids[i].explode[ship.explodeAnimNdx].anim7,asteroids[i].x, asteroids[i].y, asteroids[i].angleRadians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)
                --asteroids[i].explode[asteroids[i].explodeAnimNdx].animDone = true
                asteroids[i].x = -100 --cheap hack to prevent lasers hitting dead asteroids, by moving it off the screen
                asteroids[i].y = -100
                asteroids[i].exploding = false
            end
        else
            love.graphics.draw(asteroids[i].img, asteroids[i].x, asteroids[i].y, asteroids[i].radians,1,1,asteroids[i].img:getWidth()/2,asteroids[i].img:getHeight()/2)

        end

        --love.graphics.rectangle("line", asteroids[i].x-asteroids[i].halfWidth, asteroids[i].y-asteroids[i].halfHeight, asteroids[i].w, asteroids[i].h)

    end

end

function drawHUD() --font display info
    drawRed()

    love.graphics.print("Level: " .. level, 0, 0)
    love.graphics.print("Score: " .. score, screen_width-100, 0)

    if ship.dead then
        love.graphics.print("You have died! Press enter key to respawn", screen_width/2-175, screen_height/2)
    end

    if soundOn then
        love.graphics.print(" - Sound On", 60,0)
    else
        love.graphics.print(" - Sound Off", 60,0)
    end

    if paused then 
        love.graphics.print("Paused", screen_width/2-50, screen_height/2)
    else
    end
    
    --love.graphics.rectangle("line", shipProtectBox.x, shipProtectBox.y, shipProtectBox.w, shipProtectBox.h)

    --exploding = false 
    for i = 0,numAsteroids
    do 
        str = ""
        if exploding then
            str = "Yes"
        else
            str = "No"
        end

        --love.graphics.print("Exploding is " .. str, 0, 25)
    end

    drawNormal()


end

function love.keyreleased(key)
    if key == "space" then
       spaceDown = false
    end
    if key == "s" then 
        sDown = false 
    end
    if key == "p" then
        pDown = false
    end
 end

 function drawStars()

    for i = 0, numStars
    do
        setColor(stars[i],stars[i].glowValue)
        love.graphics.circle("fill", stars[i].x, stars[i].y, stars[i].radius, stars[i].segments) 

    end
 
    drawNormal()
 end