
% Before the days of smb2-cmmod outputted bare bone entries, there were assemblers...
% Here is an assembly file to give sample entries

#function $beginner 0x2075b0
0x0200014c  % Striker
0x07080001
0x02000143  % Cylinders
0x0708ff10
0x020000c9  % Simple
0x0708ff11
0x0200003f  % Flat Maze
0x04b00002
0x02000044  % Air Hockey
0x04b00003
0x03000000
0x00000000

#function $advanced 0x207600
0x0200000e  % Inchworms
0x07080101
0x02000123  % Pistons
0x0708ff12
0x02000124  % Soft Cream
0x0708ff13
0x02000125  % Momentum
0x07080102
0x02000063  % Dizzy System Betta
0x0e100103
0x03000000
0x00000000

#function $beginnerExtra 0x207640
0x02000137  % Charge
0x0e100004
0x0200013f  % Construction
0x0e100005
0x02000140  % Train Worm
0x07080006
0x03000000
0x00000000

#function $advancedExtra 0x207680
0x02000147  % Long Torus
0x07080104
0x0200014d  % Ooparts
0x07080105
0x02000154  % Nintendo
0x07080106
0x03000000
0x00000000


#function $table 0x2c7874
0x3e440105
0x00033550  % Beginner
0x00040105
0x000335a0  % Advanced
0x00040105
0x00033550  % Expert (points to Beginner)
0x00040105
0x000335e0  % BE EX
0x00040105
0x00033620  % AD EX
0x00040105
0x000335e0  % EX EX points to BE EX
0x00040105
0x000335a0  % Master points to Advanced
0x00040105
0x00033620  % MA EX points to AD EX
0x00040105
0x00033620  % MA EX points to AD EX
0x00040105
0x00033620  % Unuseds points to AD EX
0x00040105
0x00033620  % Unuseds points to AD EX
0x00040105
0x00033620  % Unuseds points to AD EX


