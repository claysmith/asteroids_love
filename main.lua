
function love.load()

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
    
    ship.angle = 0
    ship.angleRadians = 0
    ship.turnAmount = 5

    asteroid = {}
    asteroid.x = 200
    asteroid.y = 200

    love.window.setTitle("Love Asteroids")

    font = love.graphics.newFont(14)
    love.graphics.setFont(font)

end
   
function love.update(dt)

    processShip(dt)



end
  
function love.draw()
    drawShip()
    drawAsteroids()
    drawScore()
end

function drawShip()
    if not ship.moving then
        love.graphics.draw(ship.stillimage, ship.x, ship.y, ship.angleRadians,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

    elseif ship.moving then

        if ship.currAnim == 1 then
            love.graphics.draw(ship.animation, ship.anim1,ship.x, ship.y, ship.angleRadians,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        end
        if ship.currAnim == 2 then
            love.graphics.draw(ship.animation, ship.anim2,ship.x, ship.y, ship.angleRadians,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

        end
        if ship.currAnim == 3 then
            love.graphics.draw(ship.animation, ship.anim3,ship.x, ship.y, ship.angleRadians,1,1,ship.stillimage:getWidth()/2,ship.stillimage:getHeight()/2)

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
end


function drawAsteroids()

end

function drawScore()
    love.graphics.print("Anim Time " .. ship.animTime, 0, 0)

end

