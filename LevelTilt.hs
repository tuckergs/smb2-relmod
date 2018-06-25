
import Control.Monad
import qualified Data.ByteString.Builder as BB
import Helpers.FileStuff (copyBytes, doFileIO)
import Helpers.FloatStuff (floatToHex)
import System.IO
import System.Environment
import System.Exit

levelTiltOffset :: Integer
levelTiltOffset = 0x174C48

endOfREL :: Integer
endOfREL = 3000268

main = do
  args <- getArgs
  when (length args /= 3) $
    die "Usage: ./LevelTilt [input REL] [level tilt value] [output REL]"
  let (inFileName:levelTiltStr:outFileName:_) = args
  let levelTilt = read levelTiltStr :: Float
  let levelTiltWord = floatToHex levelTilt

  doFileIO inFileName outFileName $ \inFile outFile -> do
    let cpBytes = copyBytes inFile outFile
    cpBytes 1 levelTiltOffset
    BB.hPutBuilder outFile $ BB.word32BE levelTiltWord
    hSeek inFile RelativeSeek 4
    cpBytes (levelTiltOffset + 4) (endOfREL-1)



  
