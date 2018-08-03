
% 0x8054df94 is the amount of lives you start with

% Instruction 0x809053f8 makes 0x8054df94 hold 0x3
% 80844650 seems to tell us whether or not we went over the amount of lives we could have

% 0x8062a298 is current number of play points
% 0x804c3f70 contains a pointer to the byte that contains max amount of lives 

% 0x8062a295 seems to be max lives


% Instruction 0x803dd068 change num of play points after purchasing life
% Instruction 0x803dd078-0xd07c
%   lbz r3, 0x0001 (r4)
%   addi r0, r3, 1
%   stb r0, 0x0001 (r4)

% #function $maxLivesAtStartAlwaysThree 0x16cf78
% nop
% li r0, 3

#function $noPlayPointDecrement 0x16cf60
nop
nop
nop

#function $noMaxLiveIncrement 0x16cf78
nop
nop
nop

#function $fn803dd468 0x16d368
nop
nop
nop
li r3, 3
blr
