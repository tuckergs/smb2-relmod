# smb2-relmod

## Wat?
This repo provides miscellaneous tools to modify/analyze the main_loop rel for Super Monkey Ball 2. 

## Current tools

LevelTilt.hs modifies the degree that the stage tilts. 50 deg tilt is Super Anti-Gravity ball

PartyBallHeight.hs modifies how far from the ground a goal's party ball is

FixOverwrites.hs modifies which code in the REL is not overwritten by function 800104bc.
You need to use this if you plan to modify main_loop assembly

CmpFiles.hs outputs the differences of two RELs

## Compiling

You can compile any of these tools by using
```
ghc [tool hs file]
```
