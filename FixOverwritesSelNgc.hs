
-- FixOverwrites for sel_ngc

import FixOverwritesCommon

main = do
  let rec = FOR {
    firstOffsetEntryTable = 0x3d4c7 ,
    firstOverwriteAddress = 0x808f40b8 ,
    programName = "FixOverwritesSelNgc"
  }
  fixOverwrites rec


