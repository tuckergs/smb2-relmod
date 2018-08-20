
-- FixOverwrites for main_game. See common file for more details

import FixOverwritesCommon

main = do
  let rec = FOR {
    firstOffsetEntryTable = 0x7a924 ,
    firstOverwriteAddress = 0x808f40b8 ,
    programName = "FixOverwritesMainGame"
  }
  fixOverwrites rec
