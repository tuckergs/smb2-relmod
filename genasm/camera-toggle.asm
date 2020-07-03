% Function to make it so that pressing Z in game toggles between SMB1 and SMB2 cam modes
% This uses space after a shorter 803133cc function. So run PPCInject with this asm file and an asm file that shortens 803133cc, like simple803133cc.asm

% Free space at third Competition Mode entry (There is definitely more space before this, but I forgot the exact bounds)
% 0x8047b3dc

% 0x8047b3dc is what 0x8057cd00 was


#function $activatecam 0x26680
b $SPACE

#function $afterActivateCam after $activatecam

#function $SPACE after $fn803133cc
bl $togglecam
lis r3, 0x805c
addi r3, r3, 0xc474
lwz r0, 0 (r3)
b $afterActivateCam

#function $redirset 0x21350
bl $setcam

#function $togglecam after $fn803133cc
% check if the button is pressed and the button wasn't pressed. If not, jump to second condition
lis r3, 0x8055
addi r3, r3, 0xe076
lbz r3, 0(r3)
cmplwi r3, 76
beq .success
cmplwi r3, 1
bne .end
% r4 is button loc
.success
lis r4, 0x8014
addi r4, r4, 0x5120
% r5 is prev state loc
lis r5, 0x8048
addi r5, r5, 0xb3dc  
% If button
lwz r3, 0(r4)
lis r6, 0x0010
and r3, r3, r6
cmplw r3, r6
bne .if2
% If wasn't
lwz r3, 0(r5)
cmplwi r3, 0x0
bne .if2
% If we're in here, toggle camera state
li r3, 0x1
stw r3, 0(r5)
lis r3, 0x803E
addi r3, r3, 0xDEA8
lwz r3, 0(r3)
lis r6, 0x3FE8
cmpw r3, r6
bne .smb2
% Set to SMB1
lis r3, 0x8055
addi r3, r3, 0xe076
li r6, 1
stb r6, 0(r3)
lis r3, 0x803E
addi r3, r3, 0xDEA8
lis r6, 0x3FE6
stw r6, 0(r3)
lis r6, 0x6666
addi r6, r6, 0x6666
stw r6, 0x4(r3)
stw r6, 0x1C(r3)
lis r6, 0x3FD6
addi r6, r6, 0x6666
stw r6, 0x18(r3)
lis r6, 0x4030
stw r6, 0x28(r3)
b .end
% Set to SMB2
.smb2
lis r3, 0x8055
addi r3, r3, 0xe076
li r6, 0x4C
stb r6, 0(r3)
lis r3, 0x803E
addi r3, r3, 0xDEA8
lis r6, 0x3FE8
stw r6, 0(r3)
li r6, 0x0
stw r6, 0x4(r3)
lis r6, 0x3FE9
addi r6, r6, 0x9999
stw r6, 0x18(r3)
lis r6, 0x9999
addi r6, r6, 0x999A
stw r6, 0x1C(r3)
lis r6, 0x4040
stw r6, 0x28(r3)
% check if isn't pressed and was. If not, jump to end
% If not button
.if2
lwz r3, 0(r4)
lis r6, 0x0010
and r3, r3, r6
cmplw r3, r6
beq .end
% If was
lwz r3, 0(r5)
cmplwi r3, 0x1
bne .end
% toggle button press off
li r3, 0x0
stw r3, 0(r5)
.end
blr

#function $setcam after $togglecam
lis r3, 0x803E
addi r3, r3, 0xDEA8
lis r4, 0x3FE8
lwz r5, 0(r3)
cmplw r4, r5
bne .smb2
li r0, 76
b .end
.smb2
li r0, 1
.end
blr
