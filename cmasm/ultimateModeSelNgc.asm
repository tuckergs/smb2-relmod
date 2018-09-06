
% Use FixOverwritesSelNgc on
% 0x809028f0 to 0x8090292c

#function $part80902898 0xe8b8
bgt $part809028a4

#function $part809028a4 0xe8c4
li r0, 0

#function $part809028f0 0xe910
lis r3, 0x8055
addi r3, r3, 0xdc40  % r3 = 0x8054dc40
lwz r0, 0x0008 (r3)
oris r0, r0, 0x0200
stw r0, 0x0008 (r3)
b $part8090292c


% Back in the day of using competition mode bytes for storing ultimate progress
% #function $part809028ec 0xe90c
% ble .notMaster
% li r0, 1
% b .setUltimateByte
% .notMaster
% li r0, 0
% .setUltimateByte
% lis r3, 0x8048
% addi r3, r3, 0xb32c  % 0x8047b32c 
% stb r0, 0x0008 (r3)  % Set Ultimate byte accordingly
% b $part8090292c



#function $part8090292c 0xe94c

