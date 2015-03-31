;;Includes for each of the seperate code files written by all members.
__includes["mapgen.nls" "wallAI_2.nls" "EnemyFSM.nls" "Pathfinding.nls" "PlayerControl.nls"]

;;This allows matrices to be used.
extensions [matrix]

to baseUpdate
  
ifelse GameStarted = true
[
  if (ticks mod (21 - wallSpeed) = 0)
  [
    moveUnit  
  ]
  
  ;;Update Enemy
  updateEnemyState
]
[
  ifelse Victory = true
  [
    ;;If the player has won, display the victory screen
    playerwins
    moveunit
  ]
  [
    ;;Otherwise, the game over screen
    gameOver
    moveUnit
  ]
]


tick
wait 0.1

end





;;******************************************************************************************************

globals 
[
  GameStarted    ;;Boolean indicator for the game's playing state.  When this is true, the player can move and the enemy will move.
  Victory        ;;Boolean indicator for whether the player has won or not.
]

patches-own
[
 innerLabel 
]

breed [enemies enemy ]
breed [players player ]

enemies-own 
[ 
  state           ;;Enemy state 
  energy          ;;Energy is an integer value representing the energy.
  isResting       ;;isResting is a boolean flag indicating the enemy is in the regenerating part of the resting state.
  current-path    ;;part of the path that is left to be traversed 
]


to baseSetup

  
  ;;Initialise variables
  set GameStarted false
  set Victory false
  
  ;;Create players
  ask one-of patches with [pcolor = black]
  [
    sprout-players 1
    [
      ask patch-here 
      [
        set innerLabel "destination" 
      ]
    ]
  ]
  
  ask one-of patches with [pcolor = black and innerLabel != "destination"]
  [
    ;;Create enemies
    sprout-enemies 1 
    [
      set shape "circle"
      set heading 0
      set color yellow
      set energy 100
      set isResting false
      set state ""
      set current-path ""
    ]
  ]  
  
  ;;Set Game Start
  set GameStarted true

end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
890
711
10
10
31.905
1
10
1
1
1
0
0
0
1
-10
10
-10
10
1
1
1
ticks
30.0

BUTTON
29
35
145
68
Gen Map
init\ngenMap\nformUnits\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1733
595
1849
628
DebugMSG
DebugMSG
1
1
-1000

SLIDER
928
114
1100
147
X
X
1
10
1
1
1
NIL
HORIZONTAL

CHOOSER
1136
74
1274
119
PreferedDirection
PreferedDirection
"none" "North" "South" "East" "West" "North-East" "North-West" "South-East" "South-West"
0

SLIDER
1108
172
1319
205
directionPreferenceIncluence
directionPreferenceIncluence
10
100
90
10
1
NIL
HORIZONTAL

SLIDER
927
74
1099
107
Y
Y
51
100
51
1
1
NIL
HORIZONTAL

BUTTON
1755
655
1838
688
NIL
moveUnit
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1754
697
1841
730
NIL
gameover
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1131
26
1273
59
showWallLabels
showWallLabels
1
1
-1000

BUTTON
12
161
173
194
Play
baseUpdate
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
925
24
1097
57
wallSpeed
wallSpeed
1
20
10
1
1
NIL
HORIZONTAL

BUTTON
29
76
146
109
Call Base Setup
baseSetup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1601
349
1686
382
Player Up
PlayerUp
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
1687
386
1785
419
Player Right
PlayerRight
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
1604
428
1705
461
Player Down
PlayerDown
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
1514
392
1606
425
Player Left
PlayerLeft
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

MONITOR
1500
63
1624
108
Enemy State
[ state ] of enemy 1
17
1
11

MONITOR
1497
122
1624
167
Enemy Energy
[energy] of enemy 1
17
1
11

SLIDER
1628
63
1800
96
EnemyForwardWeight
EnemyForwardWeight
1
10
1
1
1
NIL
HORIZONTAL

SLIDER
1628
100
1800
133
EnemyLeftWeight
EnemyLeftWeight
1
10
1
1
1
NIL
HORIZONTAL

SLIDER
1628
135
1800
168
EnemyRightWeight
EnemyRightWeight
1
10
1
1
1
NIL
HORIZONTAL

TEXTBOX
1546
44
1767
74
ENEMY CONTROLS AND DISPLAYS
12
0.0
1

TEXTBOX
1552
319
1750
349
PLAYER MOVEMENT CONTROLS
12
0.0
1

TEXTBOX
916
178
1066
196
WALL CONTROLS
12
0.0
1

TEXTBOX
50
15
200
33
GAME SETUP
12
0.0
1

TEXTBOX
57
144
207
162
PLAY GAME
12
0.0
1

TEXTBOX
1761
567
1911
585
DEBUG
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

This project is a collaberative effort to make a game involving AI consisting of four main features. The first main feature is a random maze generation algorithm, the second is an algorithm that changes the maze at runtime by isolating different "shapes" that make up the maze and moving them around. The third feature is an FSM controlled enemy, and the final feature is A* pathfinding for the enemy.

## HOW IT WORKS

### Map Generation

### Changing The Maze

### Enemy FSM
The enemy has 4 underlying states: **Wander**, **Seek**, **Catch**, and **Rest**.  These states are entered and exited under certain conditions in the simulation, and the enemy's own energy value.

In the **Wander** state, it will randomly navigate the maze.

In the **Seek** state, it will aggressively move towards the player.

In the **Catch** state, it will kill the player and end the game.

In the **Rest** state, it will become immobilised and regenerate energy.

The enemy requires energy for its actions.  Energy is gained in the **Wander** and **Rest** states, and spent in the **Seek** and **Catch** states. 

### A*

## HOW TO USE IT

### Setup
Press the Generate Map button to generate the map, then press "Call Base Setup" to initialise the game.
Press the start button to start the game. 

### Playing The Game
Use the WASD or the on-screen keys to move the character. Try to get to the exit tile (violet patch). You can also experiment with the settings, which will be detailed below.

## THINGS TO NOTICE

-Shapes do not form touching eachother
-The exit always spawns on the top right, the player on the bottom left.
-Wall Shapes tend to keep their form and don't merge with others.
-Wall shapes never crash into each other or push each other.
-The enemy states in the monitor.
-The enemy energy value in the monitor.
-The player can't move through the walls.

## THINGS TO TRY

You can change : TODO things to change
- Try to turn on the "showWallLabels", this way you can see which wall sections belong together.
- Moving the X slider, the bigger the number it is, the more precentige the actual units need to vote yes to move the selection.
- Try to select an option from the PreferedDirection to make the wall prefer to move to a certain direction.
- Set the directionPreferenceIncluence which is a precentige how likely they will take your selected direction 
- Adjust the weighting sliders, and see what effect they have on the enemy's movement.

## NETLOGO FEATURES

- matrices 
- agentsets 
- includes
- lists

## We can make these


## CREDITS AND REFERENCES

Maze Generaiton : Calum Brown
Obstacle Movement : Zoltán Tompa
Enemy FSM and Player : Euan McMenemin
A* Implementarion : Adrian Lis
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
