
% This reduces the cm entries to use a minimal amount of space
% This also adds useful data for use with the unlocked level bytes
% This data tells us how to read and write whether or not a level is unlocked
% Each cm entry takes eight bytes

% Format:
%   0200            [stg id]
%   [allotted time] [unlock level data]

% Unlock Level Data Format:
% The idea is that we represent the unlocked level bytes for the unskippable levels as counters and the bytes for the skippable levels as bits, just as before 
% First byte: 
%  FF: the level being unlocked is represented by a single bit (location specified thru second byte)
%  Not FF (call this value a), read a'th byte from unlocked level bytes location, the level is unlocked iff that byte is greater than or equal to the second byte of our entry's unlock level data

% You should run FixOverwrites on the following ranges:
% 0x803132c8 0x80313360
% 0x803133cc 0x80313a78
% 0x80313ad8 0x80313c80
% 0x80313e5c 0x80314274
% 0x803144e8 0x803145fc


% ------------


#function $fn803132c8 0xa31c8
% This function calculates stage id and entry pointer for first level

% Setup (r1 is sp)
stwu r1, -0x0010 (r1)
mflr r0
stw r0, 0x0014 (r1)

% Find pointer to first entry
lis r4, 0x8055
addi r4, r4, 0xdc40  % r3 = 0x8054dc40
lwz r3, 0x0004 (r4)
lwz r4, 0x0008 (r4)
bl $fn80313a78
rlwinm r4, r3, 2, 0, 29 % r4 = r3 << 2
lis r3, 0x8048
addi r3, r3, 0xb4ec  % r3 = 0x8047b4ec
add r3, r3, r4
lwz r4, 0 (r3)

% Store stage id and fixed entry pointer
lha r0, 0x0002 (r4)
lis r3, 0x8055
addi r3, r3, 0x3970
sth r0, 0x002e (r3)
lis r3, 0x805d
addi r3, r3, 0x490c
stw r4, 0 (r3)

% Call mystery function :/
bl $fn80314274

% Cleanup and exit
lwz r0, 0x0014 (r1)
mtlr r0
addi r1, r1, 0x0010
blr


% ------------


#function $fn80313360 0xa3260


% ------------


#function $fn803133cc 0xa32cc

% Setup
stwu r1, -0x0020 (r1)
mflr r0
stw r0, 0x0024 (r1)
stw r31, 0x001c (r1)
stw r30, 0x0018 (r1)
stw r29, 0x0014 (r1)

% Startup
lis r3,0x805c
addi r3,r3,0xc474 % r0 = 0x805bc474
lwz r0, 0 (r3)
andi r0,r0,0x000A
cmplwi r0, 0
bne .end

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
lis r3, 0x805d
addi r3, r3, 0x490c
li r31,0
lwz r30, 0 (r3)
li r29,0
b .stgIdLoopEnter

% Make r30 point to the next level's stg id
.stgIdLoopBegin
cmpw r29, r4
bne .stgIdLoopIncr
li r31, 1
b .stgIdLoopEnd
.stgIdLoopIncr
addi r29, r29, 1
addi r30, r30, 8
.stgIdLoopEnter
lbz r0, 0 (r30)
cmplwi r0, 3
bne .stgIdLoopBegin
.stgIdLoopEnd
cmpwi r31, 0
beq .handleEndOfDiff

% Store next level entry pointer if we didn't hit end of diff
lis r3, 0x805d
addi r3, r3, 0x490c
stw r30, 0 (r3)
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
lhz r0, 0x0002 (r30)
lis r3, 0x8055
addi r3, r3, 0x3970
sth r0, 0x002e (r3)
bl $fn803146e0
extsh r0, r29
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
lwz r31, 0x001c (r1)
lwz r30, 0x0018 (r1)
lwz r29, 0x0014 (r1)
lwz r0, 0x0024 (r1)
mtlr r0
addi r1, r1, 0x0020
blr


% ------------


#function $blrAt80313818 0xa3718
blr


% ------------


#function $fn8031381c 0xa371c

% Setup
stwu r1, -0x0010 (r1)
mflr r0
stw r0, 0x0014 (r1)

% Challenge mode or practice mode?
lis r3, 0x805d
addi r3, r3, 0x4914
lwz r3, 0 (r3)  
cmpwi r3, 0
beq .challenge

% Practice mode
li r6, 0
lis r3, 0x805d
addi r3, r3, 0x4918
lwz r4, 0x0004 (r3)
lha r3, 0x0002 (r3)
bl $prDiffIndicatorsToNum
% Find first entry pointer
.findFirst
rlwinm r5, r3, 2, 0, 29  % r5 = r5 << 2
lis r4, 0x8048
addi r4, r4, 0xb4ec  % r4 = 0x8047b4ec
add r4, r4, r5
lwz r4, 0 (r4)
lis r3, 0x805d
addi r3, r3, 0x4918
b .loopEnter

.loopBegin
addi r6, r6, 1
lha r0, 0 (r3)
cmpw r0, r6
bne .loopNotRightEntry
lhz r3, 0x0004 (r4)
b .end
.loopNotRightEntry
addi r4, r4, 8
.loopEnter
lbz r0, 0 (r4)
cmplwi r0, 3
bne .loopBegin

li r3, 3600
b .end


% Challenge mode 
.challenge
lis r3, 0x805d
addi r3, r3, 0x490c
lwz r3, 0 (r3)  % Get entry pointer
lhz r3, 0x0004 (r3)

% Cleanup and end
.end
lwz r0, 0x0014 (r1)
mtlr r0
addi r1, r1, 0x0010
blr


% ------------


#function $fn80313950 0xa3850

% Setup
stwu r1, -0x0010 (r1)
mflr r0
stw r0, 0x0014 (r1)
stw r31, 0x000c (r1)

% Get first entry pointer of difficulty
mr r31, r4
mr r4, r5
bl $fn80313a78
rlwinm r4, r3, 2, 0, 29 % r4 = r3 << 2
lis r3, 0x8048
addi r3, r3, 0xb4ec  % r3 = 0x8047b4ec
add r3, r3, r4
lwz r0, 0 (r3)

% Calculate current level entry pointer
addi r4, r31, -1
rlwinm r4, r4, 3, 0, 28  % r4 = r4 << 3
add r0, r0, r4
lis r3, 0x805d
addi r3, r3, 0x490c
stw r0, 0 (r3)
mr r3, r0
lhz r3, 0x0002 (r3)

% Cleanup and exit
lwz r31, 0x000c (r1)
lwz r0, 0x0014 (r1)
mtlr r0
addi r1, r1, 0x0010
blr


% ------------


#function $fn80313ad8 0xa39d8

% Cleanup
stwu r1, -0x0010 (r1)
mflr r0
stw r0, 0x0014 (r1)

% Get first entry in difficulty
bl $fn80313a78
rlwinm r0, r3, 2, 0, 29
lis r3, 0x8048
addi r3, r3, 0xb4ec  % r3 = 0x8047b4ec
add r3, r3, r0
lwz r3, 0 (r3)
li r6, 0

% Get length of difficulty
.loopStart
lbz r0, 0 (r3)
cmplwi r0, 3
beq .loopExit
addi r6, r6, 1
addi r3, r3, 0x8
b .loopStart
.loopExit

mr r3, r6

.end
lwz r0, 0x0014 (r1)
mtlr r0
addi r1, r1, 0x0010
blr


% ------------


#function $fn80313ba4 0xa3aa4

% Setup
stwu r1, -0x0010 (r1)
mflr r0
stw r0, 0x0014 (r1)

% Challenge or practice?
lis r6, 0x805d
addi r6, r6, 0x4914
lwz r0, 0 (r6)
cmpwi r0, 0
beq .challenge

% Practice
lis r3, 0x805d
addi r3, r3, 0x4948
lwz r3, 0 (r3)
b .checkFinalLevel

% Challenge mode
% Get length
.challenge
stw r4, 0x000c (r1)
mr r4, r5
bl $fn80313ad8
lwz r4, 0x000c (r1)

% Are we on final level?
.checkFinalLevel
cmpw r4, r3
bne .ret0
li r3, 1
b .end
.ret0
li r3, 0

% Cleanup
.end
lwz r0, 0x0014 (r1)
mtlr r0
addi r1, r1, 0x0010
blr


% ------------


#function $fn80313c80 0xa3b80


% ------------


% Function 0x80313cc0
% This function is cancer, so I'm just going to replace parts to it...

#function $loop80313d64 0xa3c64
li r6, 1
b .loopEnter
.loopBegin
cmpw r6, r7
beq $endLoop80313d64
addi r6, r6, 1
lwz r5, 0x0014 (r3)
addi r0, r5, 8
stw r0, 0x0014 (r3)
.loopEnter
lwz r5, 0x0014 (r3)
lbz r0, 0 (r5)
cmplwi r0, 3
bne .loopBegin
b $endLoop80313d64

#function $endLoop80313d64 0xa3cbc

#function $part80313dc0 0xa3cc0
lhz r6, 0x0002 (r5)

#function $part80313df4 0xa3cf4
nop
nop

% #function $part80313e04 0xa3d04
% mulli r0, r4, 0x8

% #function $part80313e0c 0xa3d0c
% sth r6, 0x0002 (r5)
% 
% #function $part80313e24 0xa3d24
% nop

% #function $part80313e54 0xa3d54
% nop


% ------------


#function $fn80313e5c 0xa3d5c

% Setup
stwu r1, -0x0010 (r1)
mflr r0
stw r0, 0x0014 (r1)

% Get first entry in difficulty
stw r4, 0x000c (r1)
mr r4, r5
bl $fn80313a78
rlwinm r0, r3, 2, 0, 29
lis r3, 0x8048
addi r3, r3, 0xb4ec  % r3 = 0x8047b4ec
add r3, r3, r0
lwz r3, 0 (r3)

% Find right entry
lwz r4, 0x000c (r1)
li r7, 0
.loopStart
lbz r0, 0 (r3)
cmpwi r0, 3
beq .fail
cmpw r7, r4
bne .loopIncr
lhz r3, 0x0002 (r3)
b .end
.loopIncr
addi r7, r7, 1
addi r3, r3, 8
b .loopStart

.fail
li r3, 0

% Cleanup and end
.end
lwz r0, 0x0014 (r1)
mtlr r0
addi r1, r1, 0x0010
blr

% ------------


#function $fn80313f24 0xa3e24

% Setup
stwu r1, -0x0010 (r1)
mflr r0
stw r0, 0x0014 (r1)

% If stg all dip switch or some other, return 1
lis r8, 0x805c
addi r8, r8, 0xc470  % r8 = 0x805bc470
lwz r0, 0 (r8)
andi r0, r0, 0x1001
cmpwi r0, 0x1001
bne .noStgAll

li r3, 1
b .end

.noStgAll
% Get the entry pointer for the first entry in difficulty
stw r4, 0x000c (r1)
mr r4, r5
bl $fn80313a78
lwz r4, 0x000c (r1)
rlwinm r7, r3, 2, 0, 29
lis r3, 0x8048
addi r3, r3, 0xb4ec  % r8 = 0x8047b4ec
add r3, r3, r7
lwz r3, 0 (r3)

% r4 = 0 means that we want to see if a difficulty is unlocked. 
% It's basically the same thing as saying the first level is unlocked, so we will make r4 = 1
cmpwi r4, 0
bne .C1
li r4, 1
.C1
addi r4, r4, -1
mulli r4, r4, 0x8
add r3, r3, r4
lbz r6, 0x0006 (r3)
lbz r7, 0x0007 (r3)
lis r3, 0x805d
addi r3, r3, 0x48f8
cmpwi r6, 0xFF
bne .counterBytes

% Bit field bytes
rlwinm r4, r7, 29, 3, 31  % r4 = r7 >> 3
add r3, r3, r4
lbz r0, 0 (r3)
li r4, 1
rlwinm r5, r7, 0, 29, 31  % r5 = r7 & 0xFF
slw r4, r4, r5
and r4, r0, r4
cmpwi r4, 0x0
beq .ret0
b .ret1

.counterBytes
add r3, r3, r6
lbz r0, 0 (r3)
cmplw r0, r7
bge .ret1
b .ret0

.ret1
li r3, 1
b .end
.ret0
li r3, 0

% Cleanup
.end
lwz r0, 0x0014 (r1)
mtlr r0
addi r1, r1, 0x0010
blr



% ------------


#function $fn8031417c 0xa407c

% Get entry pointer
lis r3, 0x805d
addi r3, r3, 0x490c
lwz r3, 0 (r3)
% What mode of unlock byte storage?
lbz r6, 0x0006 (r3)
lbz r7, 0x0007 (r3)
lis r3, 0x805d
addi r3, r3, 0x48f8
cmpwi r6, 0xFF
bne .handleCounterBytes

% Bit field bytes
rlwinm r4, r7, 29, 3, 31  % r4 = r7 >> 3
add r3, r3, r4
lbz r0, 0 (r3)
rlwinm r4, r7, 0, 29, 31  % r4 = r7 & 0xff
li r6, 1
slw r6, r6, r4
or r0, r0, r6
stb r0, 0 (r3)
b .end

.handleCounterBytes
add r3, r3, r6
lbz r0, 0 (r3)
cmplw r0, r7
bge .end
stb r7, 0 (r3)

.end
blr


% ------------


#function $fn80314274 0xa4174


% ------------


% Function 0x80314308
% Just give us curLvl (curStgId) -> nxtLvl (nxtStgID)
#function $part80314308 0xa43e8  % start replacing at 0x803144e8
lis r3, 0x805d
addi r3, r3, 0x490c
lwz r3, 0 (r3)
lbz r0, 0x0008 (r3)
mr r4, r29
cmpwi r0, 3
beq .handleEndOfDiff

% Not end of diff
% r3 points to the current entry here
lbz r6, 0x0001 (r3)  % Get goal data
li r5, 1
b .loop1Enter
.loop1Begin
rlwinm r0, r6, 0, 31, 31
rlwinm r6, r6, 31, 1, 31
cmpwi r0, 1
bne .loop1Iter
% Add goal data
lis r3, 0x805d
addi r3, r3, 0x490c
lwz r3, 0 (r3)
rlwinm r0, r5, 3, 0, 28
add r3, r3, r0
lhz r0, 0x0002 (r3)
stw r0, 0x000C (r4)
lis r3, 0x8055
addi r3, r3, 0x3970
lhz r0, 0x0020 (r3)
add r0, r0, r5
stw r0, 0x0008 (r4)
addi r4, r4, 8
addi r31, r31, 1
.loop1Iter
addi r5, r5, 1
.loop1Enter
cmpwi r6, 0
bne .loop1Begin
b .end

.handleEndOfDiff
li r0, -1
stw r0, 0x0008 (r4)
stw r0, 0x000C (r4)

.end
b $endPart80314308


#function $endPart80314308 0xa44fc  % part stops at 0x803145fc


% ------------


#function $fn803146e0 0xa45e0

#function $replace1 0x2bbb50 
% There's an entry in a jump table that references blr 0x8031365c
% Make it reference our new blr 0x80313818
0x000a3640

