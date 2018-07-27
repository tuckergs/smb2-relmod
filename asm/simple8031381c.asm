

% Function 0x8031381c is relatively large, but this can be turned into a few lines of code
% This works with vanilla cm entries, and it doesn't sacrifice the use of specifying different times, jump distance stuff, etc.
% You get a moderate amount of space in this sense
% Use FixOverwrites on range 0x8031381c - 0x80313950

#function $fn8031381c 0xa371c
lis r3, 0x805d
addi r3, r3, 0x490c
lwz r3, 0 (r3)
lbz r0, 0 (r3)
cmplwi r0, 2
bne .default
lbz r0, 0x0001 (r3)
cmplwi r0, 1
bne .default
lwz r3, 0x0004 (r3)
b .end
.default
li r3, 3600
.end
blr

#function $fn80313950 0xa3850

