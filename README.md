# smb2-relmod

## Wat?
This repo provides miscellaneous tools to modify/analyze the various RELs for Super Monkey Ball 2. 

## Current tools

LevelTilt.hs modifies the degree that the stage tilts. 50 deg tilt is Super Anti-Gravity ball

PartyBallHeight.hs modifies how far from the ground a goal's party ball is

FixOverwrites.hs modifies which code in the main_loop REL is not overwritten by function 800104bc.
You need to use this if you plan to modify main_loop assembly

FixOverwritesMainGame.hs and FixOverwritesSelNgc.rel fix overwrites for the main_game REL and the sel_ngc REL respectively.

CmpFiles.hs outputs the differences of two RELs

BonusList.hs lets you specify which stage ids constitute bonus levels. Make sure you inject genasm/shortBonusList.asm before you use it! See the simpleBonusList.bonus.txt for a sample config for it

The sources for most of the files have instructions about how to use them, or at least will tell you the usage if you run them with no arguments

## Assembly files

I have two folders that contain assembly files, genasm and cmasm . You could use PPCInject (from my repo ppc-inject) to inject them into the corresponding RELs, which you could find out by reading the assembly file, looking at the name, or by assuming it's main_loop if all else fails. Also, you need to use the corresponding FixOverwrites tool if the file tells you to.

The genasm folder contains miscellaneous asm hacks for SMB2. 

genasm/simple803133cc.asm is a file that makes 803133cc shorter so you can have space for your own code. This is separate from my new cm entry project; it uses the vanilla cm entries. Also, this shorter version doesn't support arbitrary jump distances or different jump distances at different times. You could use the after-offset features that ppc-inject offers to place your code things after the function (using "#function $fnName after $fn803133cc"). You could then use "./PPCInject \[in REL\] \[out REL\] simple803133cc.asm yourAsmFile.asm". PPCInject will also alert you if you go over the space allotted

genasm/shortBonusList.asm lets you write a shorter bonus stage list. This list specifies what levels are bonus stages. Instructions for use are in it

genasm/masterAlwaysUnlocked.asm makes sure Master always appears in the difficulty selection menu for Challenge Mode. 

genasm/masterCanUnlockPractice.asm makes it so playing a level in Master is enough to unlock Practice Mode. Normally, you could only unlock Practice Mode by playing a level in either Beginner, Advanced, or Expert.

genasm/allowNegativeContinues.asm gives you infinite continues in the sense that it will let you have a negative amount of continues

genasm/noContinues.asm makes it so you can't continue after losing all of your lives

cmasm contains some pretty hefty hacks for the modification of challenge mode and story mode. These have bat files that you should use.

In cmasm is code that accepts a shorter challenge mode entry format with more efficient unlocked level bytes; I call these new cm entries barebones entries. See my docs/newCMEntryFormats.txt for instructions about how to inject this code into your REL.

Also in cmasm is code that accepts a new story mode entry format which specifies time along with stage id and difficulty. See my docs/newSMEntryFormats.txt for details and instructions


## Compiling

You can compile any of the tools by using
```
ghc [tool hs file]
```

PPCInject can inject assembly files into RELs
