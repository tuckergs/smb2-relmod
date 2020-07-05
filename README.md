# smb2-relmod

## Wat?
This repo provides miscellaneous tools to modify/analyze the various RELs for Super Monkey Ball 2. 

## Credits
Special thanks to CraftSpider for the initial version of the SMB1/SMB2 camera toggle code, which I slightly modified to work with any hack. Read below to see how to add it properly to your hack.

## Current tools

LevelTilt.hs modifies the degree that the stage tilts. 50 deg tilt is Super Anti-Gravity Ball

PartyBallHeight.hs modifies how far from the ground a goal's party ball is

FixOverwrites.hs modifies which code in the main_loop REL is not overwritten by function 800104bc.
You need to use this if you plan to modify main_loop assembly

FixOverwritesMainGame.hs and FixOverwritesSelNgc.rel fix overwrites for the main_game REL and the sel_ngc REL respectively.

CmpFiles.hs outputs the differences of two RELs

BonusList.hs lets you specify which stage ids constitute bonus levels. Make sure you inject genasm/shortBonusList.asm before you use short bonus list entries! See the simpleBonusList.bonus.txt for a sample config for it

VariousMod.hs currently lets you change the theme ids. See sampleVarConfig.var.txt for a sample config

The sources for most of the files have instructions about how to use them, or at least will tell you the usage if you run them with no arguments

## Assembly files

I have two folders that contain assembly files, genasm and cmasm . You could use PPCInject (from my repo ppc-inject) to inject them into the corresponding RELs, which you could find out by reading the assembly file, looking at the name, or by assuming it's main_loop if all else fails. Also, you need to use the corresponding FixOverwrites tool if the file tells you to.

The genasm folder contains miscellaneous asm hacks for SMB2. 

genasm/simple803133cc.asm is a file that makes 803133cc shorter so you can have space for your own code. This is separate from my new cm entry project; it uses the vanilla cm entries. Also, this shorter version doesn't support arbitrary jump distances or different jump distances that trigger at different times. You should use the after-offset features that ppc-inject offers to place your code snippets after the function (using "#function $fnName after $fn803133cc"). You could then use "./PPCInject \[in REL\] \[out REL\] simple803133cc.asm [one or more asm files]". If you go over the space allotted, fear not! PPCInject will yell at you and not insert the code if you go over allotted space. Also of note is that if you run two separate commands which include this asm file, the second inject will overwrite the functions in the extra space from the first inject. So you would need to put all of the asm files that use space after 803133cc in one command

genasm/camera-toggle.asm makes the Z button toggle between SMB2 and SMB1 camera. CraftSpider generously let me host this code that he originally developed for MKB2, and gave me permission to slightly modify it so that it works for any hack. I needed some extra space, so the code uses the space after function 803133cc, so you should use this in conjunction with genasm/simple803133cc.asm. Read the above 

genasm/shortBonusList.asm lets you write a shorter bonus stage list. This list specifies what levels are bonus stages. Instructions for use are in it

genasm/masterAlwaysUnlocked.asm makes sure Master always appears in the difficulty selection menu for Challenge Mode. 

genasm/masterCanUnlockPractice.asm makes it so playing a level in Master is enough to unlock Practice Mode. Normally, you could only unlock Practice Mode by playing a level in either Beginner, Advanced, or Expert.

genasm/allowNegativeContinues.asm gives you infinite continues in the sense that it will let you have a negative amount of continues

genasm/noWarpBonus.asm removes the warp bonus from going into a warp goal. Useful for packs where you want to use warp goals solely for branching to other worlds

genasm/noExtras.asm doesn't let you continue on to any of the Extras in Challenge Mode

genasm/startWithZeroContinues.asm makes it so you start off with no continues. Normally, this would make it so you can't continue after losing all of your lives. I used it with conjunction with the negative continues code snippet


cmasm contains some pretty hefty hacks for the modification of challenge mode and story mode. These have bat files that you should use.

In cmasm is code that accepts a shorter challenge mode entry format with more efficient unlocked level bytes; I call these new cm entries barebones entries. See my docs/newCMEntryFormats.txt for instructions about how to inject this code into your REL.

Also in cmasm is code that accepts a new story mode entry format which specifies time along with stage id and difficulty. See my docs/newSMEntryFormats.txt for details and instructions


## Compiling

You can compile any of the tools by using
```
ghc [tool hs file]
```

PPCInject can inject assembly files into RELs
