
-- When you are modifying REL code, function 800104bc overwrites the last 16 bits of some instructions
-- Although this behavior is required for the vanilla REL instructions, we need to disable these overwrites when we inject our own code 
-- You specify an input REL, a file name to output to, and a range in RAM where we want to disable the overwrites
-- Also, the program will output all of the overwrite addresses that it encounters before the end of the range. It will also output what type of overwrite is used
-- There is a descriptive comment at the end of the line that you should comment out if you don't want that behavior
-- Also, the base defaults to base 10, as per the Haskell norm. Use 0x if you want base 16

import Control.Applicative
import Control.Monad
import Control.Monad.Fix
import Data.Bits
import Data.Word
import qualified Data.ByteString.Builder as BB
import System.Environment
import System.Exit
import System.IO
import Text.Read

import Helpers.FileStuff
import Helpers.HexStuff

readByte :: Handle -> IO Word8
readByte = fmap (fromIntegral . fromEnum) . hGetChar

readHalf :: Handle -> IO Word16
readHalf = fmap twoToWord . replicateM 2 . readByte
  where twoToWord (a:b:_) = ((fromIntegral a) `shiftL` 8) .|. fromIntegral b

beginOffsetEntryTable :: Word32
beginOffsetEntryTable = 0x279c84
beginOverwriteAddress :: Word32
beginOverwriteAddress = 0x802701d8


main = do
  let usageStr = "Usage: ./FixOverwrites [input file] [begin of disable overwrite range (RAM)] [end of range, exclusive] [file name to output to]\nFor more info, read the source"
  args <- getArgs
  when (length args /= 4) $
    die $ usageStr
  let 
    (inFileName:beginIgnoreAddressStr:endIgnoreAddressStr:outFileName:_) = args
    readMaybePair = (readMaybe beginIgnoreAddressStr, readMaybe endIgnoreAddressStr) :: (Maybe Word32,Maybe Word32)
  case readMaybePair of
    (Just _,Just _) -> return ()
    (_,_) -> die $ "You must specify 32-bit integers for the range\n" ++ usageStr
  let (Just beginIgnoreAddress,Just endIgnoreAddress) = readMaybePair

  doFileIO inFileName outFileName $ \inFile outFile -> do
    let 
      cpBytes = copyBytes inFile outFile
      cpUntilEnd = copyUntilEnd inFile outFile
    cpBytes 1 beginOffsetEntryTable
    flip fix beginOverwriteAddress $ \loop prevOverwriteAddress -> do
      off <- readHalf inFile
      BB.hPutBuilder outFile $ BB.word16BE off
      let thisOverwriteAddress = prevOverwriteAddress + fromIntegral off
      mode <- readByte inFile
      if ((mode == 0xcb) || (thisOverwriteAddress >= endIgnoreAddress)) 
        then BB.hPutBuilder outFile $ BB.word8 mode
        else do
          let 
            nextCall = loop $ thisOverwriteAddress
          hPutStrLn stderr $ (show $ Hex $ thisOverwriteAddress) ++ " " ++ (show $ Hex $ mode) -- Comment this line to make this program be not verbose
          if ((mode `elem` [0x04,0x06]) && (beginIgnoreAddress <= thisOverwriteAddress))
            then BB.hPutBuilder outFile $ BB.word8 0x0
            else BB.hPutBuilder outFile $ BB.word8 mode
          cpBytes 1 5
          nextCall
    cpUntilEnd
