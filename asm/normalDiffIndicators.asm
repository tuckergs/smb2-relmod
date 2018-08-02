
% Normal difficulty indicators 
% For use with functions that significantly replace 0x803133cc

#function $fn80313a78 0xa3978

#function $prDiffIndicatorsToNum after $fn803133cc
li r5, 0
rlwinm r0, r4, 0, 8, 8  % Master Extra
cmpwi r0, 0
beq .notMaEX
li r3, 7
b .end
.notMaEX
rlwinm r0, r4, 0, 27, 27  % Master
cmpwi r0, 0
beq .notMa
li r3, 6
b .end
.notMa
rlwinm r0, r4, 0, 28, 28
cmpwi r0, 0
beq .afterExtra
li r5, 3
.afterExtra
add r3, r5, r3
.end
blr


