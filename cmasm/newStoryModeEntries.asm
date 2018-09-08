
% Run FixOverwrites on
%   0x80314ef0 0x80314f30
%   0x803153c0 0x803153f4

#function $fn80314ef0 0xa4df0
lis r5, 0x8048
addi r5, r5, 0xb548 
mulli r3, r3, 10
add r3, r3, r4
rlwinm r3, r3, 2, 0, 29
lwzx r3, r5, r3
rlwinm r3, r3, 16, 20, 31
blr

#function $fn80314f10 0xa4e10
lis r5, 0x8048
addi r5, r5, 0xb548 
mulli r3, r3, 10
add r3, r3, r4
rlwinm r3, r3, 2, 0, 29
lwzx r3, r5, r3
rlwinm r3, r3, 4, 28, 31
blr

#function $fn803153c0 0xa52c0
lis r5, 0x8048
addi r5, r5, 0xb548 
mulli r3, r3, 10
add r3, r3, r4
rlwinm r3, r3, 2, 0, 29
add r5, r5, r3
lhz r3, 0x0002 (r5)
blr
