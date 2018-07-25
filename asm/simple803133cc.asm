
% This is a shorter version of function 803133cc
% It doesn't respect the jump distances you set for the goals; it always uses the default jump distances
% This should also remove the need for its helper functions
% This is a BETTA version. Let me know if there are random, unexpected crashes


% Note that r1 is sp
#function $fn803133cc 0xa32cc
% Setup
0x9421ffe0
0x7c0802a6
0x90010024
0x93e1001c
0x93c10018
0x93a10014

% Startup
lis r3,0x805c
addi r3,r3,0xc474 % r0 = 0x805bc474
lwz r0, 0 (r3)
andi r0,r0,0x000A
cmplwi r0, 0
bne .end
lis r3,0x805d
addi r3,r3,0x490c % r3 = 0x805d490c
lwz r30, 0 (r3)

% Check if we entered a goal
lis r3, 0x8055
addi r3, r3, 0x3970
lwz r0, 0 (r3)
andi r6, r0, 0x0201
cmpwi r6, 0
bne .enteredGoal
rlwinm r6, r0, 0, 25, 25
cmpwi r6, 0x0
bne .C0
lis r3,0x8055
addi r3,r3,0xdc40 % r3 = 0x8054dc40
lwz r4, 0x0028 (r3)
cmpwi r4, 0x1
bne .end
.C0
andi r6, r0, 0x0006
cmpwi r6, 0x0
bne .enteredGoal
b .end

% Get goal entered and compute jump distance
.enteredGoal
lis r4, 0x805c
addi r4,r4,0xd980 % r4 = 0x805bd980
lwz r4, 0 (r4)
lwz r4, 0x000C (r4)
lwz r6, 0x0048 (r4)
lis r4, 0x8055
addi r4,r4,0x3970 % r4 = 0x80553970
lha r0, 0x000C (r4)
cmplwi r0, 0x0003
bge .C1
mulli r0,r0,20
add r6,r6,r0
b .C2
.C1
addi r6,r6,60
.C2
lbz r0, 0x0012 (r6)
cmplwi r0,0x0003
bge .end
mr r4,r0
addi r4,r4,1

% Compute next level and next stage id
lis r3,0x8055
addi r3,r3,0x3970
sth r4, 0x0022 (r3)
lis r3,0x805d
addi r3,r3,0x4910
stw r4, 0 (r3)
li r31,0
li r29,0
b .stgIdLoopEnter


% Make r30 point to the next level's stg id
.stgIdLoopBegin
lbz r0, 0 (r30)
cmplwi r0, 2
bne .stgIdLoopIncr
lbz r0, 0x0001 (r30)
cmplwi r0, 0
bne .stgIdLoopIncr
addi r29, r29, 1
cmpw r29, r4
bne .stgIdLoopIncr
li r31, 1
b .stgIdLoopEnd
.stgIdLoopIncr
addi r30, r30, 28
.stgIdLoopEnter
lbz r0, 0 (r30)
cmplwi r0, 3
bne .stgIdLoopBegin

.stgIdLoopEnd
cmpwi r31, 0
beq .handleEndOfDiff

% Store next level entry pointer if we didn't hit end of diff
addi r0, r30, 28
lis r3, 0x805d
addi r3, r3, 0x490c
stw r0, 0 (r3)
b .handleNonEndOfDiff

.handleEndOfDiff
li r0, -1
lis r3, 0x8055
addi r3, r3, 0x3970
sth r0, 0x002e (r3)
lis r3, 0x805d
addi r3, r3, 0x4910
stw r0, 0 (r3)
b .end

.handleNonEndOfDiff
lwz r0, 0x0004 (r30)
lis r3, 0x8055
addi r3, r3, 0x3970
sth r0, 0x002e (r3)
bl $fn803146e0
li r0, 16
slw r29, r29, r0
sraw r0, r29, r0 % I don't have extsh right now, slw then sraw should do the same thing
lis r3, 0x8055
addi r3, r3, 0x3970
sth r0, 0x0022 (r3)
lis r3, 0x8055
addi r3, r3, 0xdc40 % r3 = 0x8054dc40
lwz r0, 0x0028 (r3)
cmpwi r0, 2
beq .L1
lis r3, 0x8055
addi r3, r3, 0x3970
lha r5, 0x0020 (r3)
lha r4, 0x0022 (r3)
add r5, r5, r4
sth r5, 0x0020 (r3)
.L1
li r0, -1
lis r3, 0x805d
addi r3, r3, 0x4910
stw r0, 0 (r3)

.end
% Cleanup
0x83e1001c
0x83c10018
0x83a10014
0x80010024
0x7c0803a6
0x38210020
blr


#function $fn803146e0 0xa45e0

#function $blrAt80313818 0xa3718
blr

#function $replace1 0x2bbb50 
% There's an entry in a jump table that references blr 0x8031365c
% Make it reference our new blr 0x80313818
0x000a3640
