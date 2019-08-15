
{-# LANGUAGE LambdaCase #-}

import Control.Monad
import Control.Monad.Fix
import Data.Bits
import qualified Data.ByteString.Builder as BB
import Data.Monoid
import Data.Word
import System.Environment
import System.Exit
import System.IO

firstRelocationOffset = 0x279c84
firstSectionOffset = 0xd8


readBytes :: (Bits a, Integral a) => [c] -> Handle -> IO a
readBytes ls handle = foldM step 0 ls
  where 
    step accum _ = do
      ineof <- hIsEOF handle
      if ineof
        then return accum
        else hGetChar handle >>= (return . (.|.) (shiftL accum 8) . fromIntegral . fromEnum)

read1 :: Handle -> IO Word8 
read1 = readBytes [1]
read2 :: Handle -> IO Word16
read2 = readBytes [1..2]
read4 :: Handle -> IO Word32
read4 = readBytes [1..4]

data RelocationData = RD { offsetFromPrev :: Word16 , typ :: Word8 , sectNum :: Word8 , symbolOffset :: Word32 }

readRelocationData handle = liftM4 RD (read2 handle) (read1 handle) (read1 handle) (read4 handle)

sectionTable = [(0,0x0),(1,0x802701d8),(4,0x803dd608),(5,0x80444160),(6,0x8054c8e0)]


main = do
  args <- getArgs
  when (length args /= 1) $ die "Usage ./UnRelocateREL [REL]" 
  let (relFileName:_) = args

  withBinaryFile relFileName ReadWriteMode $ \file -> do
    -- Setup
    hSetBuffering file $ BlockBuffering Nothing

    -- Read relocation data
    hSeek file AbsoluteSeek firstRelocationOffset
    relocationData <- flip fix [] $ \loop ls -> do
      rd <- readRelocationData file
      if typ rd == 0xcb
        then return $ reverse ls
        else loop $ rd:ls

    -- Do relocation
    hSeek file AbsoluteSeek firstSectionOffset
    forM_ relocationData $ \rd -> do
      hSeek file RelativeSeek $ fromIntegral $ offsetFromPrev rd
      sectionOffset <- case lookup (sectNum rd) sectionTable of
        Nothing -> die $ "Section number " ++ show (sectNum rd) ++ " not supported"
        Just s -> return s
      relOffsetInRAM <- fmap (+0x80270100) $ hTell file
      let 
        symbolAddress = sectionOffset + symbolOffset rd
        ppcAddr32 = do 
          BB.hPutBuilder file $ BB.word32BE symbolAddress 
          hSeek file RelativeSeek (-4)
        ppcAddr16Lo = do
          BB.hPutBuilder file $ BB.word16BE $ fromIntegral symbolAddress 
          hSeek file RelativeSeek (-2)
        ppcAddr16Ha = do
          BB.hPutBuilder file $ BB.word16BE $ fromIntegral $ (symbolAddress + 0x8000) `shiftR` 16
          hSeek file RelativeSeek (-2)
        branchOffset = symbolAddress - fromIntegral relOffsetInRAM
        ppcRel24 = do
          curInst <- read4 file
          hSeek file RelativeSeek (-4)
          let newInst = (curInst .&. 0xfc000003) .|. (branchOffset .&. 0x03fffffc)
          BB.hPutBuilder file $ BB.word32BE newInst
          hSeek file RelativeSeek (-4)
        gotoSect = case lookup (sectNum rd) sectionTable of
          Nothing -> die $ "Section number " ++ show (sectNum rd) ++ " not supported"
          Just s -> hSeek file AbsoluteSeek $ fromIntegral s - 0x80270100
        jumpTable = [(1,ppcAddr32),(4,ppcAddr16Lo),(6,ppcAddr16Ha),(10,ppcRel24),(201,return ()),(202,gotoSect)]
      case lookup (typ rd) jumpTable of
        Nothing -> die $ "Relocation data type not supported"
        Just m -> m
    
    -- Shunt relocation data
    hSeek file AbsoluteSeek firstRelocationOffset
    BB.hPutBuilder file $ BB.word32BE 0x0000cb00 <> BB.word32BE 0x00000000
    
    


