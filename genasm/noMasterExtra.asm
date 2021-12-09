
% For main_game
% FixOverwritesMainGame on the range 0x808f6178 0x808f6240

#function $part808f6178 0x2198
% boilerplate from before
li r4, 0
lis r3, 0x8055
addi r3, r3, 14704
lha r0, 0x002a (r3)
cmpwi r0, 0x0
bne $part808f6240
lis r3, 0x8055
subi r3, r3, 9152
lwz r0, 0x0008 (r3)
rlwinm r0, r0, 0, 31, 31
cmplwi r0, 0
beq $part808f6240
% golfed code. only returns 1 for B, A, E, EX
lwz r4, 0x0004 (r3)
not r4, r4
lwz r3, 0x0008 (r3)
rlwinm r3, r3, 0, 27, 28
add r4, r4, r3
subi r4, r4, 6
rlwinm r4, r4, 1, 31, 31
b $part808f6240

#function $part808f6240 0x2260
