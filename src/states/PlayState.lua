--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.ball[1].dx = math.random(-200, 200)
    self.ball[1].dy = math.random(-50, -60)

    -- init power
    self.powerup = nil

    -- set power flag
    self.powerFlag = false

    self.powerSort = nil

    self.keyFlag = false
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    if self.powerFlag then
        self.powerup:update(dt)
    end
    self.paddle:update(dt)

    for i = 1, 3 do
        if self.ball[i].flag then
            self.ball[i]:update(dt)
        end
    end




    for i = 1, 3 do
        --if (i == 1 or i == 2 and self.ball2Flag or i == 3 and self.ball3Flag) then
        if (self.ball[i].flag) then
            if self.ball[i]:collides(self.paddle) then
                -- raise ball above paddle in case it goes below it, then reverse dy
                self.ball[i].y = self.paddle.y - 8
                self.ball[i].dy = -self.ball[i].dy

                --
                -- tweak angle of bounce based on where it hits the paddle
                --

                -- if we hit the paddle on its left side while moving left...
                if self.ball[i].x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                    self.ball[i].dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball[i].x))
                
                -- else if we hit the paddle on its right side while moving right...
                elseif self.ball[i].x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                    self.ball[i].dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball[i].x))
                end

                gSounds['paddle-hit']:play()
            end
        end
    end





    -- detect collision across all bricks with the ball
    for i = 1, 3 do
        if (self.ball[i].flag) then
            for k, brick in pairs(self.bricks) do

                -- only check collision if we're in play
                if brick.inPlay and self.ball[i]:collides(brick) then

                    -- add to score
                    if brick.tier == 3 and brick.color == 6 then
                        if self.keyFlag then
                            self.score = self.score + (brick.tier * 2000 + brick.color * 250)
                        end
                    else
                        self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    end

                    -- extend/shrink the paddle
                    if (self.score > 1000) or (self.score > 500) and self.paddle.size < 3 then
                        self.paddle.size = math.min(4, self.paddle.size + 1)
                        self.paddle.width = math.min(128, self.paddle.width + 32)
                    end


                    -- trigger the brick's hit function, which removes it from play
                    brick:hit(self.keyFlag)

                    -- power logic
                    if self.powerFlag == false and self.score > 50 and
                       (bool_to_number(self.ball[1].flag) + bool_to_number(self.ball[2].flag) + bool_to_number(self.ball[3].flag)) == 1 then
                        self.powerFlag = true

                        self.powerup = Powerup(brick.x, brick.y)
                        if self.keyFlag == false then
                            self.powerSort = math.random(1, 2)
                        else
                            self.powerSort = 1
                        end
                    end

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)

                        -- multiply recover points by 2
                        self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            ball = self.ball,
                            recoverPoints = self.recoverPoints
                        })
                    end

                    --
                    -- collision code for bricks
                    --
                    -- we check to see if the opposite side of our velocity is outside of the brick;
                    -- if it is, we trigger a collision on that side. else we're within the X + width of
                    -- the brick and should check to see if the top or bottom edge is outside of the brick,
                    -- colliding on the top or bottom accordingly 
                    --

                    -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                    if self.ball[i].x + 2 < brick.x and self.ball[i].dx > 0 then
                        
                        -- flip x velocity and reset position outside of brick
                        self.ball[i].dx = -self.ball[i].dx
                        self.ball[i].x = brick.x - 8
                    
                    -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                    elseif self.ball[i].x + 6 > brick.x + brick.width and self.ball[i].dx < 0 then
                        
                        -- flip x velocity and reset position outside of brick
                        self.ball[i].dx = -self.ball[i].dx
                        self.ball[i].x = brick.x + 32
                    
                    -- top edge if no X collisions, always check
                    elseif self.ball[i].y < brick.y then
                        
                        -- flip y velocity and reset position outside of brick
                        self.ball[i].dy = -self.ball[i].dy
                        self.ball[i].y = brick.y - 8
                    
                    -- bottom edge if no X collisions or top collision, last possibility
                    else
                        
                        -- flip y velocity and reset position outside of brick
                        self.ball[i].dy = -self.ball[i].dy
                        self.ball[i].y = brick.y + 16
                    end

                    -- slightly scale the y velocity to speed up the game, capping at +- 150
                    if math.abs(self.ball[i].dy) < 150 then
                        self.ball[i].dy = self.ball[i].dy * 1.02
                    end

                    -- only allow colliding with one brick, for corners
                    break
                end
            end
        end
    end





    -- check if the powerup collides with the paddle
    if self.powerFlag then
        if self.powerup:collides(self.paddle) then
            self.powerFlag = false
            self.powerup.x = nil
            self.powerup.y = nil
            if self.powerSort == 2 then
                self.keyFlag = true
            end

            if self.powerSort == 1 then
                for i = 1, #self.ball do
                    if self.ball[i].flag then
                        for j = 1, #self.ball do
                            if j ~= i then
                                self.ball[j].x = self.paddle.x + (self.paddle.width / 2) - 4
                                self.ball[j].y = self.paddle.y - 8
                
                                self.ball[j].dx = math.random(-200, 200)
                                self.ball[j].dy = math.random(-50, -60)
                
                                self.ball[j].flag = true
                            end
                        end
                        break
                    end
                end
            end
            

        elseif self.powerup.y >= VIRTUAL_HEIGHT then
            self.powerFlag = false
            self.powerup.x = nil
            self.powerup.y = nil
        end
    end


    for i = 1, 3 do
        if (self.ball[i].flag) then
            if self.ball[i].y >= VIRTUAL_HEIGHT then
                self.ball[i].flag = false
            end
        end
    end



    -- if ball goes below bounds, revert to serve state and decrease health
    --if self.ball[1].y >= VIRTUAL_HEIGHT then
    if (bool_to_number(self.ball[1].flag) + bool_to_number(self.ball[2].flag) + bool_to_number(self.ball[3].flag)) == 0 then
        self.health = self.health - 1
        self.paddle.size = math.max(1, self.paddle.size - 1)
        self.paddle.width = math.max(32, self.paddle.width - 32)
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end




function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render powerup falling to the bottom
    if self.powerFlag then
        self.powerup:render(self.powerSort)
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end



    self.paddle:render()

    for i = 1, 3 do
        if self.ball[i].flag then
            self.ball[i]:render()
        end
    end
    

    renderScore(self.score)
    renderHealth(self.health)
    if self.keyFlag then
        renderKey()
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end

-- code taken from: https://stackoverflow.com/questions/48230472/boolean-to-number-in-lua
function bool_to_number(value)
    return value and 1 or 0
end