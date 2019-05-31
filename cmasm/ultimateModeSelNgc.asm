
% Use FixOverwritesSelNgc on
% 0x809028b4 to 0x809028bc
% 0x809028f0 to 0x8090292c


#function $part80902898 0xe8b8
bgt $part809028a4

#function $part809028a4 0xe8c4
li r0, 0

#function $part809028b4 0xe8d4
lwz r4, 0x0008 (r3)
ori r4, r4, 0x0001
stw r4, 0x0008 (r3)
bl $firstValueWrite
nop

#function $part809028f0 0xe910
lis r3, 0x8055
addi r3, r3, 0xdc40  % r3 = 0x8054dc40
lwz r0, 0x0008 (r3)
oris r0, r0, 0x0200
stw r0, 0x0008 (r3)
b $part8090292c

#function $part8090292c 0xe94c


% Don't try this at home, folks!
#function $firstValueWrite after $part809028f0
lis r3, 0x0101
addi r3, r3, 0x0101
mullw r0, r0, r3
lis r3, 0x8048
addi r3, r3, 0xb334
stw r0, 0 (r3)
stw r0, 0x4 (r3)
blr
