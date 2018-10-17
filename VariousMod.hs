
{-# LANGUAGE LambdaCase #-}



import Control.Applicative
import Control.Monad
import Control.Monad.Fix
import qualified Data.ByteString.Builder as BB
import Data.Char
import Data.List
import Data.Monoid
import Data.Word
import System.Environment
import System.Exit
import System.IO
import Text.Read

import Helpers.FileStuff
import Helpers.MiscStuff
import Helpers.ParseMonad



-------- PARSE SCHTUFF --------

readParser :: Read a => Parse String String -> Parse String a
readParser = (=<<) $ flip (.) readMaybe $ \case
  Nothing -> empty
  Just res -> return res

parseNum :: Read a => Parse String a
parseNum = readParser $ (list1 $ spot $ isDigit) <|> (liftA2 (++) (tokens "0x") (list1 $ spot $ isHexDigit))

parseName :: Parse String String
parseName = liftA2 (:) (spot isAlpha) (list $ spot isAlphaNum)

comment :: Parse String MyLine
comment = ws >> (return "" <|> (token '%' >> list item)) >> return CommentLine

type ThemePair = (Word16,Word8)

data MyLine = CommentLine | BeginThemeLine | ThemePairLine Word16 Word8 
  deriving Show


normalState :: Parse String MyLine
normalState = comment <|> beginThemeLine 

themeState :: Parse String MyLine
themeState = comment <|> themePairLine


beginThemeLine = ws >> tokens "#themes" >> comment >> return BeginThemeLine

themePairLine = liftA2 ThemePairLine (ws *> parseNum) ((ws1 *> parseNum) <* comment)


readConfig :: String -> IO [ThemePair]
readConfig fileName = do
  inFile <- openFile fileName ReadMode
  allLns <- fmap lines $ hGetContents inFile
  rt <- parseConfig allLns
  hClose inFile
  return rt

data ParseState = NormalState | ThemeState
  deriving Eq

data ConfigLoopRecord = CLR { 
  getLines :: [[Char]] , getLineNum :: Int , 
  getState :: ParseState , getThemePairs :: [ThemePair] 
}

parseConfig :: [String] -> IO [ThemePair]
parseConfig allLns = 
  let 
    initRecord = CLR {
      getLines = allLns , getLineNum = 1 ,
      getState = NormalState , getThemePairs = []
    }
  in flip fix initRecord $ \loop curRecord -> do
    let
      curLines = getLines curRecord
      curLineNum = getLineNum curRecord
      curState = getState curRecord
      curThemePairs = getThemePairs curRecord
    case curLines of
      [] -> 
        let comparePairs (s1,_) (s2,_) = compare s1 s2
        in return $ sortBy comparePairs $ reverse curThemePairs
      (ln:lns) -> do
        let
          nextRecord = curRecord { getLines = lns , getLineNum = curLineNum + 1 }
          genErr = die $ "Error at line " ++ (show curLineNum)
          parseStore = [(NormalState,normalState),(ThemeState,themeState)]
          relevantParser = brutalLookup curState parseStore
        case parse relevantParser ln of
          Left _ -> genErr
          Right CommentLine -> loop nextRecord
          Right BeginThemeLine -> loop $ nextRecord { getState = ThemeState }
          Right (ThemePairLine stgID thID) -> loop $ nextRecord { getThemePairs = (stgID,thID):curThemePairs }

themeListOffset :: Int
themeListOffset = 0x204e48


main = do
  args <- getArgs
  when (length args /= 3) $
    die $ "Usage: ./VariousMod [in REL] [config] [out REL]"
  let (inFileName:cfgFileName:outFileName:_) = args

  sortedThemePairs <- readConfig cfgFileName

  doFileIO inFileName outFileName $ \inFile outFile -> do
    let 
      cpByte = hGetChar inFile >>= hPutChar outFile
      cpBytes1 = copyBytes inFile outFile
      cpBytes2 = copyBytes inFile outFile
      rpByte r = hSeek inFile RelativeSeek 1 >> BB.hPutBuilder outFile (BB.word8 r)
    cpBytes1 1 themeListOffset
    let 
      writeStuff curStgID (nextStgID,thID) = cpBytes2 curStgID (nextStgID-1) >> rpByte thID >> return (nextStgID+1)
    foldM_ writeStuff 0 sortedThemePairs
    copyUntilEnd inFile outFile



