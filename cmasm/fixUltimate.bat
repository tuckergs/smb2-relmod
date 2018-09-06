

..\FixOverwritesMainGame.exe mkb2.main_game.rel 0x808f61ac 0x808f6248 mkb2.main_game_fixtemp_1.rel
..\FixOverwritesMainGame.exe mkb2.main_game_fixtemp_1.rel 0x808f8dd0 0x808f8e4c mkb2.main_game_fix_for_ultimate.rel
del mkb2.main_game_fixtemp_?.rel
..\FixOverwritesSelNgc.exe mkb2.sel_ngc.rel 0x809028ec 0x8090292c mkb2.sel_ngc_fix_for_ultimate.rel
