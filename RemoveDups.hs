
{-
This merges duplicate materials in MTL files, so your TPL won't be so big
Read this carefully, as it might not work as you would expect
Program takes an in-prefix and an out-prefix. For example,
  if you want to fix conveyors.mtl, the in-prefix would be conveyors.mtl
  and the [out-prefix].mtl would specify the output mtl, and you are allowed
  to make the in-prefix and out-prefix the same
Since the program can have different in-prefixes and out-prefixes, the code 
  also generates new obj and xml files with updated OBJ/MTL information 
So, the program expects [in-prefix].(obj/mtl/xml) to exist 
  and it generates [out-prefix].(obj/mtl/xml)
-}

{-# LANGUAGE LambdaCase, TupleSections #-}

import Control.Applicative
import Control.Monad.State
import Data.Char
import Data.Maybe
import System.Environment
import System.Exit
import System.IO
import Text.XML.Light

modifySubElementWithName :: String -> (Element -> Element) -> Element -> Element
modifySubElementWithName nameToFind f (Element parName parAttribs parContent parLine) = Element parName parAttribs newParContent parLine
  where
    modContent (Elem e@(Element subName _ _ _)) = if (qName subName == nameToFind)
      then Elem (f e)
      else Elem e
    modContent c = c
    newParContent = map modContent parContent

modifyTextContent :: (String -> String) -> Element -> Element
modifyTextContent f (Element parName parAttribs parContent parLine) = Element parName parAttribs newParContent parLine
  where
    modContent (Text (CData subVerbatim subData subLine)) = Text $ CData subVerbatim (f subData) subLine
    modContent c = c
    newParContent = map modContent parContent

type Parse s = StateT s [] 

infixl 3 <||

(<||) :: Parse s a -> Parse s a -> Parse s a
m <|| n = StateT $ \s -> case runStateT m s of
  [] -> runStateT n s
  ls -> ls

parse :: Parse [s] a -> [s] -> Maybe a
parse m fstLs = 
  let vals = map fst $ filter (null . snd) $ runStateT m fstLs
  in case vals of
    (x:[]) -> Just x
    _ -> Nothing


peekElem :: Parse [s] s
peekElem = get >>= \case
  [] -> empty
  (x:xs) -> return x
 
advance :: Parse [s] ()
advance = get >>= \case
  [] -> empty
  (x:xs) -> put xs

useElem :: Parse [s] s
useElem = peekElem <* advance

useAndAssert :: (s -> Bool) -> Parse [s] s
useAndAssert p = useElem >>= liftM2 (>>) (guard . p) return

token :: Eq s => s -> Parse [s] s
token s = useAndAssert (==s)

tokens :: Eq s => [s] -> Parse [s] [s]
tokens = mapM token

useWs = useAndAssert isSpace
ws = many useWs
ws1 = some useWs
useNotWs = useAndAssert (not . isSpace)
notWs = many useNotWs
notWs1 = some useNotWs

myString = do
  a <- useNotWs 
  ls <- liftM2 (\ls b -> ls ++ [b]) (many useElem) useNotWs <|> return []
  return (a:ls)

type MaterialPair = (String,String)
data MTLLine = DontCare | NewMTLLine String | MapKDLine String
  deriving Show

parseMTLLine :: Parse String MTLLine
parseMTLLine = 
  (ws >> tokens "newmtl" >> ws1 >> fmap NewMTLLine myString <* ws)
  <|> (ws >> tokens "map_Kd" >> ws1 >> fmap MapKDLine myString <* ws)
  <|| (many useElem >> return DontCare)

parseMTL :: String -> Maybe [MaterialPair]
parseMTL = grouper . filterDontCares . map (parse parseMTLLine) . lines
  where
    filterDontCares = filter $ \case
      Just DontCare -> False
      _ -> True
    grouper (Just (NewMTLLine a):Just (MapKDLine b):ls) = fmap ((a,b):) $ grouper ls
    grouper [] = Just []
    grouper _ = Nothing

data OBJLine = OBJDontCare String | UseMTLLine String | MTLLibLine 
  deriving Show

parseOBJLine :: Parse String OBJLine
parseOBJLine =
  (ws >> tokens "usemtl" >> ws1 >> fmap UseMTLLine myString <* ws)
  <|> (ws >> tokens "mtllib" >> many useElem >> return MTLLibLine)
  <|| fmap OBJDontCare (many useElem)

parseOBJ :: String -> Maybe [OBJLine]
parseOBJ = mapM (parse parseOBJLine) . lines

groupBySameTexture :: [MaterialPair] -> [([String],String)]
groupBySameTexture = go 
  where 
    go [] = []
    go ((name,texture):ls) =
      let
        namesWithSameTexture = (name:) $ map fst $ filter ((==texture) . snd) ls
        restOfPairs = filter ((/= texture) . snd) ls
      in (namesWithSameTexture,texture) : go restOfPairs

data Contents = Contents { mtlContents :: String , objContents :: String }

generateNewMTLOBJContents :: String -> [MaterialPair] -> [OBJLine] -> Contents
generateNewMTLOBJContents outPrefix mtlPairs objLines =
  let
    namesTextureList = groupBySameTexture mtlPairs
    namesTextureIdList = zipWith (\(a,b) c -> (a,b,c)) namesTextureList [(1::Int)..]

    newMaterialPairs = map (\(_,texture,i) -> ("bagel" ++ show i, texture)) namesTextureIdList
    updateNameStore = concatMap (\(names,_,i) -> map (,"bagel" ++ show i) names) namesTextureIdList
    updateOBJLine (UseMTLLine n) = case lookup n updateNameStore of
      Nothing -> error "Your OBJ references materials that aren\'t in MTL"
      Just newName -> UseMTLLine newName
    updateOBJLine l = l
    newOBJLines = map updateOBJLine objLines
    
    materialPairToLines (name,texture) = 
      [
        "newmtl " ++ name ,
        "map_Kd " ++ texture ,
        ""
      ]
    objLineToLine (OBJDontCare str) = str
    objLineToLine (UseMTLLine name) = "usemtl " ++ name
    objLineToLine MTLLibLine = "mtllib " ++ outPrefix ++ ".mtl"
    newMTLContents = unlines $ concatMap materialPairToLines newMaterialPairs
    newOBJContents = unlines $ map objLineToLine newOBJLines
  in Contents { mtlContents = newMTLContents , objContents = newOBJContents }

modifyXML :: String -> Element -> Element
modifyXML outPrefix = modifySubElementWithName "modelImport" $ modifyTextContent $ const $ "//" ++ outPrefix ++ ".obj"

main = do
  args <- getArgs
  when (length args /= 2) $
    die $ "Usage: ./RemoveArgs [prefix for input OBJ/MTL] [prefix for output OBJ/MTL]"
  let 
    (inPrefix:outPrefix:[]) = args
  
  inMTLContents <- readFile $ inPrefix ++ ".mtl"
  inOBJContents <- readFile $ inPrefix ++ ".obj"
  inXMLElementMaybe <- fmap parseXMLDoc $ readFile $ inPrefix ++ ".xml"
  let
    mtlPairsMaybe = parseMTL inMTLContents
    objLinesMaybe = parseOBJ inOBJContents
  mtlPairs <- maybe (die "Bad MTL Parse") return mtlPairsMaybe
  objLines <- maybe (die "Bad OBJ Parse") return objLinesMaybe
  inXMLElement <- maybe (die "Bad XML Parse") return inXMLElementMaybe
  let 
    newContents = generateNewMTLOBJContents outPrefix mtlPairs objLines
    newXMLElement = modifyXML outPrefix inXMLElement
  writeFile (outPrefix ++ ".mtl") (mtlContents newContents)
  writeFile (outPrefix ++ ".obj") (objContents newContents)
  writeFile (outPrefix ++ ".xml") (showElement newXMLElement)


