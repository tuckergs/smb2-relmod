
% For sel_ngc
% Fix overwrites from 0x808ff7a4 to 0x808ff7ec

% Normally, playing a level in Master is not enough to unlock Practice Mode
% This hack makes this the case

#function $part808ff7a4 0xb7c4
li r3, 0

.loop
addi r4, r3, 1
stw r4, 0x0008 (r1)
li r4, 0
li r5, 0
bl @fn80313f24
cmpwi r3, 0
bne $part808ff80c
lwz r3, 0x0008 (r1)
cmpwi r3, 0x3
bge .loopEnd
b .loop

.loopEnd
li r3, 2
li r4, 0
li r5, 0x0018
bl @fn80313f24
cmpwi r3, 0
bne $part808ff80c
% b $part808ff7ec

#function $part808ff7ec 0xb80c
#function $part808ff80c 0xb82c
#offset @fn80313f24 0xffa1ff44
