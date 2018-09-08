
..\FixOverwrites.exe mkb2.main_loop.rel 0x80314ef0 0x80314f30 mkb2.main_loop_temp1.rel 
..\FixOverwrites.exe mkb2.main_loop_temp1.rel 0x803153c0 0x803153f4 mkb2.main_loop_fix_for_new_story.rel
PPCInject.exe mkb2.main_loop_fix_for_new_story.rel mkb2.main_loop_code_for_new_story.rel newStoryModeEntries.asm vanillaSMOrderInNewSMEntries.asm

del mkb2.main_loop_temp1.rel
