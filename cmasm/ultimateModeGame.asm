
% Run FixOverwritesMainGame with these ranges
% 0x808f61ac 0x808f6248
% 0x808f8dd0 0x808f8e4c

#function $part808f6190 0x21b0  
beq $noCourse

#function $part808f61a4 0x21c4
bne $noCourse

#function $fn808f5bc4Part 0x21cc
lis r3, 0x8055
addi r3, r3, 0xdc40  % r3 = 0x8054dc40
lwz r4, 0x0008 (r3)  % Bit field
rlwinm r0, r4, 0, 8, 8  % Master Extra bit
cmpwi r0, 0
bne $noCourse

% lis r4, 0x8048 
% addi r4, r4, 0xb32c  % r4 = 0x8047b32c
% lbz r4, 0x0008 (r4)  % Load Ultimate byte
rlwinm r4, r4, 0, 6, 6  % Load byte for Ultimate (originally Master diff bit)
cmpwi r4, 0
bne $nextCourse

lwz r4, 0x0008 (r3)  % Bit field
andi r0, r4, 0x0018  % Master and Extra bit
cmpwi r0, 0x0008  % If we not in Extra, we just want next course
bne $nextCourse
lwz r4, 0x0004 (r3)  % Value
cmpwi r4, 0x2  % If Expert Extra, we want new course
beq $nextCourse
b $noCourse

#function $nextCourse 0x2268

#function $noCourse 0x227c


#function $fn808f8d9cPart 0x4df0
lis r3, 0x8055
addi r3, r3, 0xdc40  % 0x8054dc40
lwz r5, 0x0004 (r3)
lwz r3, 0x0008 (r3)

rlwinm r0, r3, 0, 27, 27  % Check bit for Master
cmpwi r0, 0
beq .checkExpertExtra
oris r3, r3, 0x0080
b .update

.checkExpertExtra
rlwinm r0, r3, 0, 28, 28  % Check Extra
cmpwi r0, 0
beq .toggle
cmpwi r5, 2
bne .toggle
% Set Master stuff
ori r3, r3, 0x0010
stw r3, 0x000c (r1)
bl @fn803dc5b0
cmpwi r3, 0
bne .afterMasterCalls
bl @fn803dc598
.afterMasterCalls
lwz r3, 0x000c (r1)
b .update

.toggle
rlwinm r0, r3, 29, 31, 31  % Get Extra bit
xori r3, r3, 0x0008
add r5, r5, r0
% Go to .update

.update
mr r0, r3
lis r3, 0x8055
addi r3, r3, 0xdc40  % 0x8054dc40
stw r5, 0x0004 (r3)
stw r0, 0x0008 (r3)
b $fn808f8d9cBack

#function $fn808f8d9cBack 0x4e6c

#offset @fn803dc5b0 0xFFAE85D0

#offset @fn803dc598 0xFFAE85b8
