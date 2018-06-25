
import Control.Monad
import qualified Data.ByteString.Builder as BB
import Helpers.FileStuff (copyBytes, doFileIO)
import Helpers.FloatStuff (floatToHex)
import System.IO
import System.Environment
import System.Exit

partyBallHeightOffset :: Integer
partyBallHeightOffset = 0x176304

endOfREL :: Integer
endOfREL = 3000268

main = do
  args <- getArgs
  when (length args /= 3) $
    die "Usage: ./LevelTilt [input REL] [level tilt value] [output REL]"
  let (inFileName:partyBallHeightStr:outFileName:_) = args
  let partyBallHeight = read partyBallHeightStr :: Float
  let partyBallHeightWord = floatToHex partyBallHeight

  doFileIO inFileName outFileName $ \inFile outFile -> do
    let cpBytes = copyBytes inFile outFile
    cpBytes 1 partyBallHeightOffset
    BB.hPutBuilder outFile $ BB.word32BE partyBallHeightWord
    hSeek inFile RelativeSeek 4
    cpBytes (partyBallHeightOffset + 4) (endOfREL-1)



  
