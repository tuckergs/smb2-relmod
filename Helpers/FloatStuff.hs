
{-# LANGUAGE FlexibleContexts #-}

module Helpers.FloatStuff (floatToHex) where


import Data.Array.ST (newArray, readArray, MArray, STUArray)
import Data.Array.Unsafe (castSTUArray)
import Data.Word
import GHC.ST (runST, ST)


-- This came from Stack Overflow, with me writing it slightly differently

floatToHex :: Float -> Word32
floatToHex x = runST $ cast x

{-# INLINE cast #-}
cast :: (MArray (STUArray s) a (ST s), MArray (STUArray s) b (ST s)) => a -> ST s b
cast x = newArray (0 :: Int,0) x >>= castSTUArray >>= flip readArray 0
