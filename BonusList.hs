
-- See simpleBonusList.bonus.txt to see an example config 
-- It'll tell you how to specify shorter bonus lists

{-# LANGUAGE LambdaCase #-}

import Control.Applicative
import Control.Monad
import Control.Monad.Fix
import qualified Data.ByteString.Builder as BB
import Data.Char
import Data.Monoid
import Data.Word
import System.Environment
import System.Exit
import System.IO
import Text.Read

import Helpers.FileStuff
import Helpers.ParseMonad


parseNumMaybe :: Read a => Parse String (Maybe a)
parseNumMaybe = fmap readMaybe $ (list1 $ spot $ isDigit) <|> (tokens "0x" >> fmap ("0x"++) (list1 $ spot $ isHexDigit))

parseName :: Parse String String
parseName = do
  c <- spot isAlpha
  cs <- list $ spot isAlphaNum
  return (c:cs)

data EntryType = Vanilla | Short
  deriving Eq

data MyLine = EntryTypeLine EntryType | StageIDLine Word16 | CommentLine

comment :: Parse String MyLine
comment = ws >> (return "" <|> (token '%' >> list item)) >> return CommentLine


parseLine :: Parse String MyLine
parseLine = comment <|> stageIDLine <|> entryTypeLine
  where
    stageIDLine = do
      ws
      (parseNumMaybe >>=) $ \case
        Nothing -> empty
        Just stgID -> do
          comment
          return $ StageIDLine stgID
    entryTypeLine = do
      ws
      tokens "#entryType"
      ws1
      entryType <- 
        (parseName >>=) $ \case
          "Vanilla" -> return Vanilla
          "Short" -> return Short
          _ -> empty
      comment
      return $ EntryTypeLine entryType
      
readConfig :: String -> IO (EntryType,[Word16])
readConfig fileName = do
  inFile <- openFile fileName ReadMode
  allLns <- fmap lines $ hGetContents inFile
  rt <- parseConfig allLns
  hClose inFile
  return rt

data ConfigLoopRecord = CLR { getLineNum :: Int ,
                              getLines :: [String] ,
                              getEntryType :: EntryType ,
                              getEntryList :: [Word16]
                            }

parseConfig :: [String] -> IO (EntryType,[Word16])
parseConfig allLns = 
  let
    initRecord = CLR { getLineNum = 1 ,
                        getLines = allLns ,
                        getEntryType = Vanilla ,
                        getEntryList = []
                    }
  in 
    flip fix initRecord $ \loop curRecord -> do
      let
        curLineNum = getLineNum curRecord
        curLines = getLines curRecord
        theEntryType = getEntryType curRecord
        curEntryList = getEntryList curRecord
        warning = do
          hPutStrLn stderr $ "Do you wish to continue? Type y to continue, or anything else to exit"
          response <- getLine
          when (response /= "y") $ exitFailure
      case curLines of
        [] -> do
          when ((theEntryType == Vanilla) && (length curEntryList > 9)) $ do
            hPutStrLn stderr $ "You are allowed 9 bonus levels using the vanilla bonus stage list format"
            hPutStrLn stderr $ "Use the short format (put \"#entryType Short\" at the start of the file) to get up to 19"
            exitFailure
          when ((theEntryType == Short) && (length curEntryList > 19)) $ do
            hPutStrLn stderr $ "You are allowed 19 bonus levels using the short bonus stage list format"
            hPutStrLn stderr $ "Throw TwixNinja411 into dumpsters until he implements a feature to move the bonus stage list"
          return (theEntryType, reverse curEntryList)
        (ln:lns) -> do
          let nextRecord = curRecord { getLineNum = curLineNum + 1 , getLines = lns }
          case parse parseLine ln of
            Left _ -> die $ "Error on line " ++ (show curLineNum)
            Right CommentLine -> loop nextRecord
            Right (EntryTypeLine entryType) -> do
              when (not $ null curEntryList) $ 
                die $ "You must specify the entry type before specifying the entries. \nI know it\'s a stupid rule, but I want everyone to specify their entry types at the top."
              loop $ nextRecord { getEntryType = entryType }
            Right (StageIDLine stgID) ->
              loop $ nextRecord { getEntryList = stgID:curEntryList }
                
writeTable :: Handle -> (EntryType,[Word16]) -> IO ()
writeTable outFile (Vanilla,stgIDs) = 
  BB.hPutBuilder outFile $ (<> BB.word32BE 0) $ mconcat $ flip map stgIDs $ 
    \stgID -> BB.word16BE 0 <> BB.word16BE stgID
writeTable outFile (Short,stgIDs) =
  BB.hPutBuilder outFile $ (<> BB.word16BE 0xffff) $ mconcat $ flip map stgIDs $
    \stgID -> BB.word16BE stgID


bonusListOffset = 0x176118

main = do
  args <- getArgs
  when (length args /= 3) $
    die $ "Usage: ./BonusList [in REL] [cfg] [out REL]"
  let (inFileName:cfgFileName:outFileName:_) = args

  cfgPairs <- readConfig cfgFileName
  doFileIO inFileName outFileName $ \inFile outFile -> do
    let 
      cpBytes = copyBytes inFile outFile
      cpUntilEnd = copyUntilEnd inFile outFile
    cpBytes 1 bonusListOffset
    writeTable outFile cfgPairs
    whereWeAre <- hTell outFile
    hSeek inFile AbsoluteSeek whereWeAre
    cpUntilEnd

          
    
