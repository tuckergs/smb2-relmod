
-- Fixes the overwrites for main_loop
-- Read the common file for more details

import FixOverwritesCommon
import Data.Word

main = do
  let rec = FOR {
    firstOffsetEntryTable = 0x279c84 ,
    firstOverwriteAddress = 0x802701d8 ,
    programName = "FixOverwrites"
  }
  fixOverwrites rec
