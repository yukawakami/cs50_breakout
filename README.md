# CS50G_breakout

<a href= "https://cs50.harvard.edu/games/2018/weeks/2/">https://cs50.harvard.edu/games/2018/weeks/2/</a>

## Objectives
Read and understand all of the Breakout source code from Lecture 2.<br>
Add a powerup to the game that spawns two extra Balls.<br>
Grow and shrink the Paddle when the player gains enough points or loses a life.<br>
Add a locked Brick that will only open when the player collects a second new powerup, a key, which should only spawn when such a Brick exists and randomly as per the Ball powerup.

## Specification
Add a Powerup class to the game that spawns a powerup (images located at the bottom of the sprite sheet in the distribution code). This Powerup should spawn randomly, be it on a timer or when the Ball hits a Block enough times, and gradually descend toward the player. Once collided with the Paddle, two more Balls should spawn and behave identically to the original, including all collision and scoring points for the player. Once the player wins and proceeds to the VictoryState for their current level, the Balls should reset so that there is only one active again.<br>

Grow and shrink the Paddle such that it’s no longer just one fixed size forever. In particular, the Paddle should shrink if the player loses a heart (but no smaller of course than the smallest paddle size) and should grow if the player exceeds a certain amount of score (but no larger than the largest Paddle). This may not make the game completely balanced once the Paddle is sufficiently large, but it will be a great way to get comfortable interacting with Quads and all of the tables we have allocated for them in main.lua!<br>

Add a locked Brick (located in the sprite sheet) to the level spawning, as well as a key powerup (also in the sprite sheet). The locked Brick should not be breakable by the ball normally, unless they of course have the key Powerup! The key Powerup should spawn randomly just like the Ball Powerup and descend toward the bottom of the screen just the same, where the Paddle has the chance to collide with it and pick it up. You’ll need to take a closer look at the LevelMaker class to see how we could implement the locked Brick into the level generation. Not every level needs to have locked Bricks; just include them occasionally! Perhaps make them worth a lot more points as well in order to compel their design. Note that this feature will require changes to several parts of the code, including even splitting up the sprite sheet into Bricks!



## Changes made

### main.lua:
Line 72: Generation of powerup quads<br>
Lines 309 - 311: function for rendering the key flag on top of the screen

### Ball.lua:
Line 32: defined a self.flag for having more than one ball later on

### Brick.lua:
Lines 52 - 56: gold particles for the locked brick<br>
Line 93: modified Brick:hit() to accept keyFlag as a parameter, used to check whether the locked brick was hit while having the keyFlag, and then remove it<br>
Lines 115 - 120, 137: code to remove the locked brick

### Dependencies.lua:
Line 38: Included Powerup

### LevelMaker.lua:
Lines 45 - 52, 131 - 137: code to generate a random locked brick

### Util.lua:
Line 58: changed the last parameter of GenerateQuads to 24 in order to be able to generate a quad for the key<br>
Lines 129 - 143: created GenerateQuadsPower for the powerups

### PlayState.lua:
self.ball, which was used throughout the file, has been replaced with a table of balls, self.ball[i], to account for up to 3 balls<br>
Lines 35 - 46: entering the PlayState with only one ball, initializing necessary flags<br>
Lines 64 - 66: for updating the powerup in case the powerFlag is set<br>
Lines 117 - 121: to account the score added when hitting the key brick<br>
Lines 125 - 129: to extend/shrink the paddle<br>
Line 133: changed brick:hit() to take the argument self.keyFlag, to check whether the key brick was hit or not<br>
Lines 135 - 146: power logic, for when a brick is hit<br>
Lines 231 - 266: check if the powerup collides with the paddle. If it does and the powerSort is 1(balls), generate two more balls, is the powerSort is 2(key), set the keyFlag to true<br>
Lines 269 - 275: code for checking which balls have gone below bounds<br>
Line 281: if all three balls go below the boundary, decrease health and paddle size<br>
Lines 324 - 327: code for rendering the powerup falling to the bottom<br>
Lines 347 - 349: code for rendering the keyFlag next to the health hearts<br>
Lines 369 - 371: function to convert a boolean to an integer

### ServeState.lua:
Lines 30 - 36, 45 - 46, 70: modified self.ball to a table of balls, starting the game with only ball[1]

### VictoryState.lua:
Lines 30 - 31, 49: changed so that ball[1] tracks the player


## License

This project is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.<br>
For details, see the [full license](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).
