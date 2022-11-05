
function boxBoxCollision(x1,y1,w1,h1,x2,y2,w2,h2) --pass in like this so I can translate coords above it

    if ((x1 > x2 or (x1 + w1) > x2) and (x1 < (x2 + w2))) then
        if ((y1 > y2 or (y1 + h1) > y2) and (y1 < (y2 + h2))) then 
            return true
        end
    end

    return false 
end

function circleXYCollision(pos,circle)

    if distance(circle.x,circle.y,pos.x,pos.y) <= circle.radius then
        return true
    end

    return false 
end


function boxXYCollision(point, box)

    if point.x > box.x and point.x < box.x + box.w then
        if point.y > box.y and point.y < box.y + box.h then
            return true
        end 
    end

    return false; 
end

function boxCircleCollision(box, circle)

    if boxXYCollision(circle, box) then
        return true
    end

    gx = 0
    gy = 0

    x2 = box.x + box.w/2
    y2 = box.y + box.h/2

    nw2 = box.x + box.w
    nh2 = box.y + box.h

    -- box frame is above radius frame
    if y2 <= circle.y then
        -- middle
        if circle.x >= box.x and circle.x <= nw2 then
            gx = circle.x
            gy = nh2
        end
        -- left
        if circle.x > nw2 then
            gx = nw2
            gy = nh2
        end
        -- right
        if circle.x < box.x then
            gx = box.x
            gy = nh2
        end
   -- box frame below radius frame
    elseif y2 > circle.y then
       --middle
        if circle.x >= box.x and circle.x <= nw2 then
            gx = circle.x
            gy = box.y
        end
        -- left
        if circle.x > nw2 then
            gx = nw2
            gy = box.y
        end       
        -- right
        if circle.x < box.x then
            gx = box.x
            gy = box.y
        end
    end
    
    -- boxframe is on right middle of radframe
    if circle.x < x2 and nh2 > circle.y and box.y < circle.y then
        gx = box.x
        gy = circle.y
    -- boxframe is on left middle of radframe
    elseif circle.x > x2 and nh2 > circle.y and box.y < circle.y then
        gx = nw2
        gy = circle.y
    end

    if (distance(circle.x, circle.y, gx, gy) <= circle.radius) then
        return true
    end

    return false

end

function distance(x1, y1, x2, y2)
    return math.sqrt(math.pow(x2-x1, 2) + math.pow(y2-y1, 2))
end
