
Powerup = Class{}

-- initialize
function Powerup:init(x, y)
    self.x = x
    self.y = y

    self.dy = 75

    self.width = 16
    self.height = 16
end

-- for when the powerup collides with the paddle
function Powerup:collides(target)
    --if self.x + self.width > target.x or target.x + target.width > self.x then
    if (self.x + self.width > target.x and self.x + self.width < target.x + target.width) or 
       (self.x > target.x and self.x < target.x + target.width) then
        if (self.y + self.height > target.y and self.y + self.height < target.y + target.height) or 
           (self.y > target.y and self.y < target.y + target.height) then
            return true
        end
    end
    return false
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:render(sort)
    love.graphics.draw(gTextures['main'], gFrames['powerup'][sort], self.x, self.y)
end
