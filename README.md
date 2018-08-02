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

I also have an asm folder, which hosts assembly files compatible with my ppc-inject assembler. (http://github.com/tuckergs/ppc-inject). You need to patch main_loop to use them, unless it's specified otherwise

forceThreeLivesAtStart.asm makes it so you always start challenge mode with three lives.

simple803133cc.asm is a file that makes 803133cc shorter so you can have space for your own code. This is separate from my new cm entry project; it uses the vanilla cm entries. Also, this shorter version doesn't support arbitrary jump distances or different jump distances at different times. You could use the after-offset features that ppc-inject offers to place your code things after the function (using "#function $fnName after $fn803133cc"). You could then use "./PPCInject \[in REL\] \[out REL\] simple803133cc.asm yourAsmFile.asm". PPCInject will also alert you if you go over the space allotted

I also made code that accepts a shorter challenge mode entry format with more efficient unlocked level bytes; I call these new cm entries barebones entries. To use them right out of the box, use my fixBareBone.sh script (or follow the steps in it) and then use PPCInject with asm files bareBoneEntries.asm and normalDiffIndicators.asm. Look at testBareBoneEntries.asm for an example of the format, and use it with PPCInject if you want to experiment with those entries. Also note that if you want to inject code at the end of 803133cc, you have to place it after $prDiffIndicatorsToNum


## Compiling

You can compile any of these tools by using
```
ghc [tool hs file]
```
