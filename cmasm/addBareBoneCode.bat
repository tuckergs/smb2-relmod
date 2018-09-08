
..\FixOverwrites.exe mkb2.main_loop.rel 0x803132c8 0x80313360 mkb2.main_loop_temp1.rel
..\FixOverwrites.exe mkb2.main_loop_temp1.rel 0x803133cc 0x80313a78 mkb2.main_loop_temp2.rel
..\FixOverwrites.exe mkb2.main_loop_temp2.rel 0x80313ad8 0x80313c80 mkb2.main_loop_temp3.rel
..\FixOverwrites.exe mkb2.main_loop_temp3.rel 0x80313e5c 0x80314274 mkb2.main_loop_temp4.rel
..\FixOverwrites.exe mkb2.main_loop_temp4.rel 0x803144e8 0x803145fc mkb2.main_loop_fix_for_barebones.rel

PPCInject.exe mkb2.main_fix_for_barebones.rel mkb2.main_loop_code_for_barebones.rel bareBoneEntries.asm normalDiffIndicators.asm

del mkb2.main_loop_temp?.rel
