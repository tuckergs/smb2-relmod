
module Helpers.FileStuff (copyBytes, doFileIO) where

import Control.Monad
import System.IO

copyBytes :: Handle -> Handle -> Integer -> Integer -> IO ()
copyBytes inFile outFile a b = forM_ [a..b] $ const $ hGetChar inFile >>= hPutChar outFile

doFileIO :: String -> String -> (Handle -> Handle -> IO ()) -> IO ()
doFileIO inFileName outFileName k = do
  inFile <- openFile inFileName ReadMode
  outFile <- openFile outFileName WriteMode
  hSetBinaryMode inFile True
  hSetBinaryMode outFile True
  hSetBuffering outFile (BlockBuffering Nothing)

  k inFile outFile

  hClose inFile
  hClose outFile
