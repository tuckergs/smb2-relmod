

..\FixOverwrites.exe mkb2.main_loop.rel 0x803133cc 0x80313818 mkb2.main_loop_temp_1.rel
..\FixOverwritesMainGame.exe mkb2.main_game.rel 0x808f61ac 0x808f6248 mkb2.main_game_fixtemp_1.rel
..\FixOverwritesMainGame.exe mkb2.main_game_fixtemp_1.rel 0x808f8dd0 0x808f8e4c mkb2.main_game_fix_for_ultimate.rel
del mkb2.main_game_fixtemp_?.rel
..\FixOverwritesSelNgc.exe mkb2.sel_ngc.rel 0x809028b4 0x809028bc mkb2.sel_ngc_fixtemp_1.rel
..\FixOverwritesSelNgc.exe mkb2.sel_ngc_fixtemp_1.rel 0x809028ec 0x8090292c mkb2.sel_ngc_fix_for_ultimate.rel
del mkb2.sel_ngc_fixtemp_?.rel

PPCInject.exe mkb2.main_game_fix_for_ultimate.rel mkb2.main_game_ultimate.rel ultimateModeGame.asm
PPCInject.exe mkb2.main_loop_temp_1.rel mkb2.main_loop_ultimate.rel ultimateModeLoop.asm ..\genasm\simple803133cc.asm
PPCInject.exe mkb2.sel_ngc_fix_for_ultimate.rel mkb2.sel_ngc_ultimate.rel ultimateModeSelNgc.asm
