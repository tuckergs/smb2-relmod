
-- This program compares two RELs and find the differences between them
-- It prints out ranges of offsets that differ
-- The files must be the same size
-- The file prints out offsets in hex

import Control.Monad
import Control.Monad.Fix
import System.Environment
import System.Exit
import System.IO

import Helpers.HexStuff

main = do
  args <- getArgs
  when (length args /= 2) $
    die $ "Usage: ./CmpFiles [file 1] [file 2]"
  let (fileName1:fileName2:_) = args

  file1 <- openFile fileName1 ReadMode
  file2 <- openFile fileName2 ReadMode 
  ranges <- flip fix (0,(-1),False,[] :: [(Int,Int)]) $ \loop (curPos,stPos,curState,curRanges) -> do
    ineof <- hIsEOF file1
    if ineof
      then do
        endPos <- fmap fromIntegral $ hTell file1
        return $ if curState then (stPos,endPos-1):curRanges else curRanges
      else do
        c1 <- hGetChar file1
        c2 <- hGetChar file2
        let charsEqual = c1 == c2
        if not charsEqual
          then 
            if curState
              then loop (curPos+1,stPos,curState,curRanges)
              else loop (curPos+1,curPos,True,curRanges) -- Start detecting range
          else
            if curState
              then loop (curPos+1,(-1),False,(stPos,curPos - 1):curRanges) -- Range completed
              else loop (curPos+1,(-1),False,curRanges)
  forM_ (reverse ranges) $ \(st,ed) -> 
    putStrLn $ "[" ++ (show $ Hex $ st) ++ ".." ++ (show $ Hex $ ed) ++ "]"
  hClose file1
  hClose file2

