
% This makes function 80313c80 read a bonus list of halfwords. The terminator is the 0xffff halfword
% For example, 0x0141 0x0142 0xffff is the bonus list for making Centrifugal, Swing Bridges the sole bonus stages under this new code.

#function $fn80313c80UseShortsPt1 0xa3b94
lhz r0, 0 (r5)

#function $fn80313c80UseShortsPt2 0xa3ba8
addi r5, r5, 2
lha r0, 0 (r5)
cmpwi r0, -1
