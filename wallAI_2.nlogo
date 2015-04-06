; Author: Zoltan Tompa - 2015
;
;
; notes: 
;       by default, patches get a groupID variable with the initial value of 0 !!!
;       word wrapping has to be disabled
;       wall movement doesn't takes the player or enemy's into account, can just crushes them
;       ;* notation is used for depricated code
;
;
;; BUGs::

;;TO-DOs

;;Ideas; 

;- make Bricks they wanted to move initially more weighted in direction voting (use slider for ptc) than those who didn't
;- add functionality to Unit reFormation (Join/Split Units)
;/ they can "prefer" to join smaller/bigger/no prefference Units
;/ there will be a precentage for Join or not (one random no (on slider) for the whol Unit)
;/ Bricks vote to separate themselfs form their Units (and may join aother one if it's 1 tile away) (value on slider)

patches-own [
             patchID    ; a simple counter for all patches to be numbered starts with 1
             groupID    ; to group Units together
             movingWill   ;how much the individual Bricks want to move (scale 0-10)
             movingDir  ; in which of the 4 directions the unit wants to move (-1 +1 | col row)
             ]


globals [
  
   ;X the precentige need to be met for a unit to decide to move
   ;Y the precentige need to be met for a unit to decide on moving direction
    
  groupIdCounter         ;to keep track of the number of units
  patchIDcounter         ;to number the patches
  isfirtsredfound
  
  UnitIDList             ;list of existing UnitIDs
  UnitMovingDir          ;agreed direction of Unit movement
  validMovesList         ;list of valid moves
  canUnitMove            ;is selected Unit free to move to the agreed movement?
  UnitWantsMove          ;is selected Unit wants to move at all?
  
  UnitMoveCounter        ;how much move happened overall
  TurnCounter            ;how much move could had happened (if 100% move)
  
  WorldRowCount          ;how many rows does the world exist of (on one side)
  WorldColCount          ;how many colums does the world exist of (on one side)

  curCol
  curRow
  
  BrickColor             ;the color of the wall
  BGColor                ;the color of the background

  
  
  selectedUnit  ;the selected unit choosen to allow to move

         ]
;;;M1.2
;;a method to initialise and set up the global variables
;-----------------------------------------------------------------------------------------
to init
    ;clear the world
    clear-all
    clear-patches 
    reset-ticks
    set UnitMoveCounter 0
    set TurnCounter 0
    clear-all-plots 
    clear-globals 

    ;set up PUBLIC variables
    set WorldRowCount 16 ;
    set WorldColCount 16 ; the dimensions of the non-wrapping world
    set BrickColor  red
    set BGColor  blue

    ;set up PRIVATE variables
    set groupIdCounter 0 ;reset the groupcounter
    set isfirtsredfound false;
    set patchIDcounter 1;
    set curRow WorldRowCount
    
    set UnitWantsMove false
    set validMovesList []
    

    initrow
  
end


;;;M1
;;method to generate a random map
;-----------------------------------------------------------------------------------------
to genmap
  
  init
  
; set BG to BGColor
  ask patches [set pcolor BGColor] 
  
;generate a random map, so I can play with it =)
  ask n-of filling_level patches [set pcolor BrickColor]
  
end



;;;M2
;;method to find neighbouring bricks, and form Units with them
;-----------------------------------------------------------------------------------------
to formUnits
  
  ;; form the first row (call method)
  set curCol (- WorldColCount - 1)
  let i  (- WorldColCount)
  while [ i < (WorldColCount + 1)]
  [

    firstRow
    set  i i + 1
  ]
   
     
  ;; form the other rows (call method)  
  let j (- WorldColCount)
  while [ j < (WorldColCount + 1)]  
  [
    set i (- WorldRowCount)
    while [ i < (WorldRowCount + 1)]
  [
    secRow
    set  i (i + 1)
  ]
  
  
  set  j (j + 1)
  ]
    
;;call method to generate a valid groupIDlist  
buildUnitIDList
  
  
end

;;;M2.1
;;method to form units in the first row
;-----------------------------------------------------------------------------------------
to firstRow

  
  set curCol curCol + 1
  
  
  
      if curCol = (WorldColCount + 1) [ initrow set curRow curRow - 1 stop ]


    ask patch curCol curRow 
       [
         ;number every patch for easier processing
         set patchID patchIDcounter
         set patchIDcounter patchIDcounter + 1
         
         ;check if patch is a Brick or not
         ifelse pcolor = BrickColor [ 
                               if isfirtsredfound = false [set groupID 1 set groupIdCounter groupIdCounter + 2 set isfirtsredfound true]
                               
                               if groupID = 0[ set groupID groupIdCounter set groupIdCounter groupIdCounter + 1]
                               
                               set plabel groupID
                               
                               if curCol != (WorldColCount) [ask patch (curCol + 1) curRow [if pcolor = BrickColor [ set groupID [groupID] of patch curCol curRow  set plabel groupID]]] ;ask ahead but not in the last Col
                               ;ask patch curCol (curRow - 1) [if pcolor = BrickColor [ set groupID [groupID] of patch curCol curRow  set plabel groupID]] ;ask below
                               
                              ]
         
         
         
         [  ] ; is not a Brick    
        ]
  
end

;;;M2.2
;;method to form Units in every additional row
;-----------------------------------------------------------------------------------------
to secRow
  set curCol curCol + 1
      if curCol = (WorldColCount + 1) [ initrow set curRow curRow - 1 stop ]
  
  let rowAboveBrick  false;

    ask patch curCol curRow 
       [
         
         ;number every patch for easier processing
         set patchID patchIDcounter
         set patchIDcounter patchIDcounter + 1
         
         ;check if patch is a Brick or not
         ifelse pcolor = BrickColor [ 
                               
                               
                               ifelse [groupID] of patch curCol (curRow + 1) != 0 [ set groupID [groupID] of patch curCol (curRow + 1)  set rowAboveBrick  true] ;ask above
                               [if groupID = 0 [set groupID groupIdCounter set groupIdCounter groupIdCounter + 1]]
                               set plabel groupID
                               
                               
                              if curCol != (- WorldColCount) [ask patch (curCol - 1) curRow [if (pcolor = BrickColor) and ((groupID = 0) or (rowAboveBrick = true)) [ set groupID [groupID] of patch curCol curRow set plabel groupID  ]]] ;ask behind, except in the first col
                              if curCol != (WorldColCount)  [ask patch (curCol + 1) curRow [if (pcolor = BrickColor) and ((groupID = 0) or (rowAboveBrick = true)) [ set groupID [groupID] of patch curCol curRow set plabel groupID  ]]] ;ask ahead, except the last col
                               
                              ]
         
         
         
         [ ] ; is not a Brick    
        ]
    
end


;;;M2.1.1
;;method to reset the col number in the end of every row
;-----------------------------------------------------------------------------------------
to initrow
  
      set curCol  (- WorldRowCount - 1)
  
end




;;;M2.3
;; a method to build a list of valid Unit IDs
;-----------------------------------------------------------------------------------------
to buildUnitIDList

let i 1
set UnitIDList []

while [i <= patchIDcounter]

[

ask patches with [(patchID = i)] [ if (groupID) != 0 [ ifelse(member? groupID UnitIDList) [] [ set UnitIDList lput groupID UnitIDList ]  ] ]
  
set i i + 1  
]

if (DebugMSG) [show UnitIDList]

end



;;;M4.1
;; method to pick a random unit
;-----------------------------------------------------------------------------------------
to pickOneUnit
  
;from the 2nd instance, set the previously picked unit back the the BGColor
ifelse (selectedUnit = 0) [][ask patches with [groupID = selectedUnit] [set pcolor BrickColor]]

  
set selectedUnit  one-of UnitIDList ; gives a number between 1 and the number of groups
if (DebugMSG) [print selectedUnit]
ask patches with [groupID = selectedUnit] [set pcolor green]

tick  
  
end

;;;M4.2
;;method to find out if Bricks wants to move more than X or not
;-----------------------------------------------------------------------------------------
to decideIfMoving
  
  let AVG  0
  ask patches with [groupID = selectedUnit] [set movingWill random 11] ;assign a moovingwill value to each Brick 0-10
  set AVG sum [movingWill] of patches with [groupID = selectedUnit]
  set AVG AVG / count patches with [groupID = selectedUnit]

  if (DebugMSG) [print AVG]
  
  ifelse (AVG >= X) [ if (DebugMSG) [print "to infinity, and beyound!!!"] set UnitWantsMove true] [ set UnitWantsMove false] ;check if more Bricks than X wants to move or not
  
end

;;;M4.3
;;method to find out which way Bricks wants to go   [0=left|1=up|2=right|3=down]
;-----------------------------------------------------------------------------------------
to decideUnitMovingDirection
  
 set UnitMovingDir  -1 ; set to an invalid value

 
  
 while [UnitMovingDir < 0]
 [ 
  
    ask patches with [groupID = selectedUnit] ;assign a moovingDir value to each Brick 0-3
   [
     
     if (PreferedDirection = "none")[ set movingDir one-of validMovesList]
     if (PreferedDirection = "North")[ ifelse ( (random 10 < (directionPreferenceIncluence / 10) ) and (member? 1 validMovesList)) [set movingDir 1] [set movingDir one-of validMovesList] ]
     if (PreferedDirection = "South")[ ifelse ( (random 10 < (directionPreferenceIncluence / 10) ) and (member? 3 validMovesList)) [set movingDir 3] [set movingDir one-of validMovesList] ]
     if (PreferedDirection = "East") [ ifelse ( (random 10 < (directionPreferenceIncluence / 10) ) and (member? 2 validMovesList)) [set movingDir 2] [set movingDir one-of validMovesList] ]
     if (PreferedDirection = "West") [ ifelse ( (random 10 < (directionPreferenceIncluence / 10) ) and (member? 0 validMovesList)) [set movingDir 0] [set movingDir one-of validMovesList] ]


     if ((PreferedDirection = "North-East") and ((member? 1 validMovesList) or (member? 2 validMovesList))) [ ifelse (random 10 < (directionPreferenceIncluence / 10)) [ifelse ( random 2 = 0) [set movingDir 1] [set movingDir 2]] [set movingDir one-of validMovesList] ]
     if ((PreferedDirection = "North-East") and ( not (member? 1 validMovesList) or  not (member? 2 validMovesList))) [set movingDir one-of validMovesList]

     if ((PreferedDirection = "North-West") and ((member? 1 validMovesList) or (member? 0 validMovesList))) [ ifelse (random 10 < (directionPreferenceIncluence / 10)) [ifelse ( random 2 = 0) [set movingDir 1] [set movingDir 0]] [set movingDir one-of validMovesList] ]
     if ((PreferedDirection = "North-West") and ( not (member? 1 validMovesList) or not (member? 0 validMovesList))) [set movingDir one-of validMovesList]
     
     if ((PreferedDirection = "South-East") and ((member? 3 validMovesList) or (member? 2 validMovesList))) [ ifelse (random 10 < (directionPreferenceIncluence / 10)) [ifelse ( random 2 = 0) [set movingDir 3] [set movingDir 2]] [set movingDir one-of validMovesList] ]
     if ((PreferedDirection = "South-East") and ( not (member? 3 validMovesList) or  not (member? 2 validMovesList))) [set movingDir one-of validMovesList]
     
     if ((PreferedDirection = "South-West") and ((member? 3 validMovesList) or (member? 0 validMovesList))) [ ifelse (random 10 < (directionPreferenceIncluence / 10)) [ifelse ( random 2 = 0) [set movingDir 1] [set movingDir 0]] [set movingDir one-of validMovesList] ]
     if ((PreferedDirection = "South-West") and ( not (member? 3 validMovesList) or  not (member? 0 validMovesList))) [set movingDir one-of validMovesList]
    ]


  let _left count patches with [(groupID = selectedUnit) and (movingDir = 0)]
  let _up count patches with [(groupID = selectedUnit) and (movingDir = 1)]
  let _right count patches with [(groupID = selectedUnit) and (movingDir = 2)]
  let _down count patches with [(groupID = selectedUnit) and (movingDir = 3)]

  let _leftPCT (_left / count patches with [groupID = selectedUnit]) * 100
  let _upPCT (_up / count patches with [groupID = selectedUnit]) * 100
  let _rightPCT (_right / count patches with [groupID = selectedUnit]) * 100
  let _downPCT (_down / count patches with [groupID = selectedUnit]) * 100
  
  if (_leftPCT > Y) [set UnitMovingDir 0]
  if (_upPCT > Y) [set UnitMovingDir 1]
  if (_rightPCT > Y) [set UnitMovingDir 2]
  if (_downPCT > Y) [set UnitMovingDir 3]  
     
 ]  

if (DebugMSG) [print UnitMovingDir]
 
end

;;;M4.4
;; a method to see if the selected Unit can move in the selected direction
;; FOR A UNIT TO BE ABLE TO MOVE TO A DIRECTION, LOCATIONS TO ALL BRICKS CURRENT LOC. +1 IN THE MOVING DIRECTIONS HAS TO HAVE EITHER THE UNIT ID, OR 0 (EMPTY)
;-----------------------------------------------------------------------------------------
to canMove
  
  let i  0
  let unitMemberList []
  set canUnitMove true ;set to true
  
  let moveRowDiff  0
  let moveColDiff  0
  
  ;interpret UnitMovingDir
  if (UnitMovingDir = 0) [set moveColDiff -1]
  if (UnitMovingDir = 1) [set moveRowDiff 1]
  if (UnitMovingDir = 2) [set moveColDiff 1]
  if (UnitMovingDir = 3) [set moveRowDiff -1]
  
  
  ask patches with [groupID = selectedUnit] [set unitMemberList lput patchID unitMemberList] ;making a list of all the members in the actual Unit
  

  ; while: If reporter reports false, exit the loop. Otherwise run commands and repeat. 
  while [(i < length unitMemberList)] ; loop ends if all members report true, or one member reports false
  [
    ;check for world boundaries
    ;*ask patches with [patchID = item i unitMemberList] [ if ( ((pxcor + moveColDiff) < -16) or ((pxcor + moveColDiff) > 16) or ((pycor + moveRowDiff) < -16) or ((pycor + moveRowDiff) > 16)) [set canUnitMove false]]
      ask patches with [patchID = item i unitMemberList] [ if ((((pxcor + moveColDiff) < (- WorldColCount)) or((pxcor + moveColDiff) > (WorldColCount))) or (((pycor + moveRowDiff) < (- WorldRowCount)) or((pycor + moveRowDiff) > (WorldRowCount)))) [set canUnitMove false]]

    
    
    if (canUnitMove = true)
    [
    ;check for otherwise ok movement (other Units can be in the way)
    ask patches with [patchID = item i unitMemberList] [ set pcolor yellow ask patch (pxcor + moveColDiff) (pycor + moveRowDiff) [ ifelse((groupID = 0)or(groupID = selectedUnit)) [] [set canUnitMove false]]]    
    ]
    
    set i i + 1
    

  ]
  
  ;for DEBUGGING
 if (DebugMSG) [ifelse (canUnitMove = false)[print "can't go =("][ print "off we goooo =D"]]
  
end


;;;M4.5
;; a method to physically move the selected unit, if the movement is AUTOHISED by "canMove" method
;-----------------------------------------------------------------------------------------
to doMove
  
  let i  0
  let unitMemberList []

  
  let moveRowDiff  0
  let moveColDiff  0
  
  ;interpret UnitMovingDir
  if (UnitMovingDir = 0) [set moveColDiff -1]
  if (UnitMovingDir = 1) [set moveRowDiff 1]
  if (UnitMovingDir = 2) [set moveColDiff 1]
  if (UnitMovingDir = 3) [set moveRowDiff -1]
  
  
  
  ask patches with [groupID = selectedUnit] [set groupID 0 ask patch (pxcor + moveColDiff) (pycor + moveRowDiff) [ set pcolor pink]]
  
  ask patches with [pcolor = pink] [ set pcolor BrickColor set groupID selectedUnit set plabel groupID]
  ask patches with [(groupID = 0) and (pcolor != orange)] [set pcolor BGColor set plabel ""]
  
  set  UnitMoveCounter UnitMoveCounter + 1
  
  tick
  
end



;;;M4
;; a method to tie together the 5 methods: pickOneUnit, decideIfMoving, decideUnitMovingDirection ,canMove ,doMove
;-----------------------------------------------------------------------------------------

to moveUnit
  
set TurnCounter TurnCounter + 1

clearValidMovesList

let exitloop false

  ;pick a random unit
  pickOneUnit
   
   ;wait 2
   
  ;see if they want to move
  decideIfMoving
  
  if (UnitWantsMove = true)
  [
   
    
    while [exitloop = false]
    [
      
      ;vote for a direction
      decideUnitMovingDirection
      
      ;see if it's a valid move
      canMove
      
      ifelse (canUnitMove = true) [set exitloop true] [ set validMovesList remove UnitMovingDir validMovesList ]  
      if (length validMovesList = 0) [if (DebugMSG) [print "NO VALID MOVE !!!!!!"]  set exitloop true]
      
    ]
    
    if (length validMovesList != 0)
    [
      ;move there
      doMove
    ]
    
  ]
  
end



;;;M4.6
;; a method to reset the validMovesList
;-----------------------------------------------------------------------------------------
to clearValidMovesList
  
  ;clear validlist
  while [(length validMovesList) > 0]
  [
    set validMovesList remove-item 0 validMovesList  
  ]
  
  ;refill it
  set validMovesList fput 0 validMovesList
  set validMovesList lput 1 validMovesList
  set validMovesList lput 2 validMovesList
  set validMovesList lput 3 validMovesList

  
end
@#$#@#$#@
GRAPHICS-WINDOW
241
10
837
627
16
16
17.76
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
71
61
146
94
NIL
genmap
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
18
190
51
filling_level
filling_level
0
500
239
1
1
NIL
HORIZONTAL

BUTTON
988
367
1066
400
NIL
firstRow
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
991
410
1065
443
NIL
secRow
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
67
108
152
141
NIL
formUnits
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
969
451
1066
484
NIL
pickOneUnit
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
24
213
196
246
X
X
0
10
3
1
1
NIL
HORIZONTAL

SLIDER
24
261
196
294
Y
Y
51
100
51
1
1
NIL
HORIZONTAL

SLIDER
25
308
197
341
braveBrickExtraVote
braveBrickExtraVote
100
500
100
10
1
NIL
HORIZONTAL

BUTTON
955
533
1065
566
NIL
canMove
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
888
493
1065
526
NIL
decideUnitMovingDirection
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
990
576
1065
609
NIL
doMove
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
65
157
148
190
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
1

MONITOR
25
354
109
399
Genrated Units
length UnitIDList
0
1
11

MONITOR
123
354
228
399
Total Unit Moves
UnitMoveCounter
0
1
11

PLOT
26
411
226
561
Moving precentige
totat moving opportunity
actual move counter
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ((UnitMoveCounter / (TurnCounter + 1)) * 100)"

SLIDER
875
79
1086
112
directionPreferenceIncluence
directionPreferenceIncluence
10
100
90
10
1
NIL
HORIZONTAL

CHOOSER
903
17
1041
62
PreferedDirection
PreferedDirection
"none" "North" "South" "East" "West" "North-East" "North-West" "South-East" "South-West"
2

SWITCH
949
322
1065
355
DebugMSG
DebugMSG
1
1
-1000

TEXTBOX
947
295
1097
314
DEBUG SELECTION
15
0.0
1

@#$#@#$#@
## WHAT IS IT?

This Model emulates a basic artificial life environment, where a random map is generated and thereafter Units are formed. Then the Units try to move around the world restrained by rules.

## HOW IT WORKS

After map-formation, individual tiles (Bricks) look around in four directions for neighbouring Bricks and try to form Units with them.
Units stay together for the rest of the game.
After Unit-formation a Unit gets selected randomly and its members ask to vote for moving or staying. If they vote to move, they re-vote for the direction of movement.
This can be influenced.
Finally the Unit moves (if the movement is possible) and another Unit is selected and the cycle starts over...


## HOW TO USE IT

First set the Filling level with the slider.
Then generate a map.
Form initial Units.
Press moveUnits.

Control the moving willingness with the X slider. (the bigger the X the less likely they move)
Control the required direction agreement precentige with the Y slider. (the bigger the Y the less more votes needed)
Control the extra vote Bricks get that wanted to move in the first place. (not implemented yet)
Select the prefered moving direction from the drop-down list
Control the prefrecence influence with the slider below the list.


'Generated Units' meter shows the number of individual Units currently on the map.
'Total Unit Moves' shown the number of actual movements Units made so far
'Moving precentige' shows the ratio between the total possible movements and actual movements Units made


## THINGS TO NOTICE

Wall units stay together during the run.
Wall shapes never crash into each other or push each other.
If the Y slider is really high, Units take way longer to agree on a direction.
Walls never vote to move to the same direction if they already found out it's invalid in the current iteration.


## THINGS TO TRY

Change the moving direction / influence to see how the Bricks react to the change.


## CREDITS AND REFERENCES

Developed by Zoltan Tompa - 2015, for the Team8 shared AI project.
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
NetLogo 5.2-RC2
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
