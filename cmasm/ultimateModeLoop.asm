
% Figures out which ranking board to use?

#function $part8038b4ec 0x11b3ec
rlwinm r3, r3, 0, 6, 6

#function $part8038b4f4 0x11b3f4
beq $part8038b550

#function $part8038b500 0x11b400
li r0, 3
b $part8038b550

#function $part8038b550 0x11b450



% Text writing at name entry?

#function $part8039895c 0x12885c
rlwinm r3, r3, 0, 6, 6

#function $part80398964 0x128864
beq $part803989c0

#function $part80398970 0x128870
li r0, 3
b $part803989c0

#function $part803989c0 0x1288c0


% Writes score to ranking table

#function $part8038d98c 0x11d88c
rlwinm r3, r3, 0, 6, 6

#function $part8038d994 0x11d894
beq $part8038d9f0

#function $part8038d9a0 0x11d8a0
li r0, 3
b $part8038d9f0

#function $part8038d9f0 0x11d8f0


% Puts ranking table for diff back to where it's supposed to be?

#function $part8038a3e0 0x11a2e0
rlwinm r0, r0, 0, 6, 6

#function $part8038a3e8 0x11a2e8
beq $part8038a444

#function $part8038a3f4 0x11a2f4
li r3, 3
b $part8038a444

#function $part8038a444 0x11a344





% Various text
#function $nameEntryText 0x2265f8 
0x2D554C54 
0x494D4154 
0x45204D4F 
0x44452D00

#function $rankingScreenText 0x241f44
0x554C542E 
0x204D4F44 
0x45000000





