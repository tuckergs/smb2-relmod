# smb2-relmod

## Wat?
This repo provides miscellaneous tools to modify/analyze the main_loop rel for Super Monkey Ball 2. 

## Current tools

LevelTilt.hs modifies the degree that the stage tilts. 50 deg tilt is Super Anti-Gravity ball

PartyBallHeight.hs modifies how far from the ground a goal's party ball is

FixOverwrites.hs modifies which code in the REL is not overwritten by function 800104bc.
You need to use this if you plan to modify main_loop assembly

CmpFiles.hs outputs the differences of two RELs

The sources for most of the files have instructions about how to use them, or at least will tell you the usage if you run them with no arguments

## Assembly files

I also have an asm folder, which hosts assembly files compatible with my ppc-inject assembler. (http://github.com/tuckergs/ppc-inject)

simple803133cc.asm is a file that makes 803133cc shorter so you can have space for your own code. This is separate from my new cm entry project; it uses the vanilla cm entries. Also, this shorter version doesn't support arbitrary jump distances. You could use the after-offset features that ppc-inject offers to place your code things after the function (using "#function $fnName after $fn803133cc"). You could then use "./PPCInject \[in REL\] \[out REL\] simple803133cc.asm yourAsmFile.asm"



## Compiling

You can compile any of these tools by using
```
ghc [tool hs file]
```
