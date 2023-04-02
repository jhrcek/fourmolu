{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TupleSections #-}

import ConfigData
import Control.Monad ((>=>))
import Data.List (intercalate, isSuffixOf, stripPrefix)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Maybe (fromMaybe, mapMaybe)
import Text.Printf (printf)

main :: IO ()
main = do
  writeFile "../src/Ormolu/Config/Gen.hs" configGenHs
  writeFile "../fourmolu.yaml" fourmoluYamlOrmoluStyle

configGenHs :: String
configGenHs =
  unlines_
    [ "{- FOURMOLU_DISABLE -}",
      "{- ***** DO NOT EDIT: This module is autogenerated ***** -}",
      "",
      "{-# LANGUAGE DeriveGeneric #-}",
      "{-# LANGUAGE LambdaCase #-}",
      "{-# LANGUAGE OverloadedStrings #-}",
      "{-# LANGUAGE RankNTypes #-}",
      "",
      "module Ormolu.Config.Gen",
      "  ( PrinterOpts (..)",
      unlines_ $ map (printf "  , %s (..)" . fieldTypeName) fieldTypes,
      "  , emptyPrinterOpts",
      "  , defaultPrinterOpts",
      "  , defaultPrinterOptsYaml",
      "  , fillMissingPrinterOpts",
      "  , parsePrinterOptsCLI",
      "  , parsePrinterOptsJSON",
      "  , parsePrinterOptType",
      "  )",
      "where",
      "",
      "import qualified Data.Aeson as Aeson",
      "import qualified Data.Aeson.Types as Aeson",
      "import Data.Functor.Identity (Identity)",
      "import Data.Scientific (floatingOrInteger)",
      "import qualified Data.Text as Text",
      "import GHC.Generics (Generic)",
      "import Text.Read (readEither, readMaybe)",
      "",
      "-- | Options controlling formatting output.",
      "data PrinterOpts f =",
      indent . mkPrinterOpts $ \(fieldName', Option {..}) ->
        unlines_
          [ printf "-- | %s" description,
            printf "  %s :: f %s" fieldName' type_
          ],
      "  deriving (Generic)",
      "",
      "emptyPrinterOpts :: PrinterOpts Maybe",
      "emptyPrinterOpts =",
      indent . mkPrinterOpts $ \(fieldName', _) ->
        fieldName' <> " = Nothing",
      "",
      "defaultPrinterOpts :: PrinterOpts Identity",
      "defaultPrinterOpts =",
      indent . mkPrinterOpts $ \(fieldName', Option {default_}) ->
        fieldName' <> " = pure " <> renderHs default_,
      "",
      "-- | Fill the field values that are 'Nothing' in the first argument",
      "-- with the values of the corresponding fields of the second argument.",
      "fillMissingPrinterOpts ::",
      "  forall f.",
      "  Applicative f =>",
      "  PrinterOpts Maybe ->",
      "  PrinterOpts f ->",
      "  PrinterOpts f",
      "fillMissingPrinterOpts p1 p2 =",
      indent . mkPrinterOpts $ \(fieldName', _) ->
        printf "%s = maybe (%s p2) pure (%s p1)" fieldName' fieldName' fieldName',
      "",
      "parsePrinterOptsCLI ::",
      "  Applicative f =>",
      "  (forall a. PrinterOptsFieldType a => String -> String -> String -> f (Maybe a)) ->",
      "  f (PrinterOpts Maybe)",
      "parsePrinterOptsCLI f =",
      "  pure PrinterOpts",
      indent' 2 . unlines_ $
        [ unlines_
            [ "<*> f",
              indent . unlines_ $
                [ quote name,
                  quote (getCLIHelp option),
                  quote (getCLIPlaceholder option)
                ]
            ]
          | option@Option {name, fieldName = Just _} <- options
        ],
      "",
      "parsePrinterOptsJSON ::",
      "  Applicative f =>",
      "  (forall a. PrinterOptsFieldType a => String -> f (Maybe a)) ->",
      "  f (PrinterOpts Maybe)",
      "parsePrinterOptsJSON f =",
      "  pure PrinterOpts",
      indent' 2 . unlines_ $
        [ "<*> f " <> quote name
          | option@Option {name, fieldName = Just _} <- options
        ],
      "",
      "{---------- PrinterOpts field types ----------}",
      "",
      "class Aeson.FromJSON a => PrinterOptsFieldType a where",
      "  parsePrinterOptType :: String -> Either String a",
      "",
      "instance PrinterOptsFieldType Int where",
      "  parsePrinterOptType = readEither",
      "",
      "instance PrinterOptsFieldType Bool where",
      "  parsePrinterOptType s =",
      "    case s of",
      "      \"false\" -> Right False",
      "      \"true\" -> Right True",
      "      _ ->",
      "        Left . unlines $",
      "          [ \"unknown value: \" <> show s,",
      "            \"Valid values are: \\\"false\\\" or \\\"true\\\"\"",
      "          ]",
      "",
      unlines_
        [ unlines_ $
            case fieldType of
              FieldTypeEnum {..} ->
                [ mkDataType fieldTypeName (map fst enumOptions),
                  "  deriving (Eq, Show, Enum, Bounded)",
                  ""
                ]
              FieldTypeADT {..} ->
                [ mkDataType fieldTypeName adtConstructors,
                  "  deriving (Eq, Show)",
                  ""
                ]
          | fieldType <- fieldTypes
        ],
      unlines_
        [ unlines_ $
            case fieldType of
              FieldTypeEnum {..} ->
                [ printf "instance Aeson.FromJSON %s where" fieldTypeName,
                  printf "  parseJSON =",
                  printf "    Aeson.withText \"%s\" $ \\s ->" fieldTypeName,
                  printf "      either Aeson.parseFail pure $",
                  printf "        parsePrinterOptType (Text.unpack s)",
                  printf "",
                  printf "instance PrinterOptsFieldType %s where" fieldTypeName,
                  printf "  parsePrinterOptType s =",
                  printf "    case s of",
                  unlines_
                    [ printf "      \"%s\" -> Right %s" val con
                      | (con, val) <- enumOptions
                    ],
                  printf "      _ ->",
                  printf "        Left . unlines $",
                  printf "          [ \"unknown value: \" <> show s",
                  printf "          , \"Valid values are: %s\"" (renderEnumOptions enumOptions),
                  printf "          ]",
                  printf ""
                ]
              FieldTypeADT {..} ->
                [ printf "instance Aeson.FromJSON %s where" fieldTypeName,
                  printf "  parseJSON =",
                  indent' 2 adtParseJSON,
                  printf "",
                  printf "instance PrinterOptsFieldType %s where" fieldTypeName,
                  printf "  parsePrinterOptType =",
                  indent' 2 adtParsePrinterOptType,
                  printf ""
                ]
          | fieldType <- fieldTypes
        ],
      "defaultPrinterOptsYaml :: String",
      "defaultPrinterOptsYaml = " <> show fourmoluYamlFourmoluStyle,
      ""
    ]
  where
    mkPrinterOpts :: ((String, Option) -> String) -> String
    mkPrinterOpts f =
      let fieldOptions = mapMaybe (\o -> (,o) <$> fieldName o) options
       in unlines_
            [ "PrinterOpts",
              indent . unlines_ $
                [ printf "%c %s" delim (f option)
                  | (option, i) <- zip fieldOptions [0 ..],
                    let delim = if i == 0 then '{' else ','
                ],
              "  }"
            ]

    mkDataType name cons =
      unlines_ $
        "data " <> name
          : [ printf "  %c %s" delim con
              | (con, i) <- zip cons [0 ..],
                let delim = if i == 0 then '=' else '|'
            ]

    renderEnumOptions enumOptions =
      renderList [printf "\\\"%s\\\"" opt | (_, opt) <- enumOptions]

    getCLIHelp Option {..} =
      let help = fromMaybe description (cliHelp cliOverrides)
          choicesText =
            case type_ `Map.lookup` fieldTypesMap of
              Just FieldTypeEnum {enumOptions} ->
                printf " (choices: %s)" (renderEnumOptions enumOptions)
              _ -> ""
          defaultText =
            printf " (default: %s)" $
              fromMaybe (hs2yaml type_ default_) (cliDefault cliOverrides)
       in concat [help, choicesText, defaultText]

    getCLIPlaceholder Option {..}
      | Just placeholder <- cliPlaceholder cliOverrides = placeholder
      | "Bool" <- type_ = "BOOL"
      | "Int" <- type_ = "INT"
      | otherwise = "OPTION"

-- | Fourmolu config with ormolu-style PrinterOpts used to format source code in fourmolu repository.
fourmoluYamlOrmoluStyle :: String
fourmoluYamlOrmoluStyle = unlines $ header <> config
  where
    header =
      [ "# ----- DO NOT EDIT: This file is autogenerated ----- #",
        "",
        "# Options should imitate Ormolu's style"
      ]
    config =
      [ printf "%s: %s" name (hs2yaml type_ ormolu)
        | Option {..} <- options
      ]

-- | Default fourmolu config that can be printed via `fourmolu --print-defaults`
fourmoluYamlFourmoluStyle :: String
fourmoluYamlFourmoluStyle = unlines_ config
  where
    config =
      [ printf "# %s\n%s: %s\n" (getComment opt) name (hs2yaml type_ default_)
        | opt@Option {..} <- options
      ]

    renderEnumOptions enumOptions =
      renderList [printf "\"%s\"" opt | (_, opt) <- enumOptions]

    getComment Option {..} =
      let help = fromMaybe description (cliHelp cliOverrides)
          choicesText =
            case type_ `Map.lookup` fieldTypesMap of
              Just FieldTypeEnum {enumOptions} ->
                printf " (choices: %s)" (renderEnumOptions enumOptions)
              _ -> ""
       in concat [help, choicesText]

{----- Helpers -----}

fieldTypesMap :: Map String FieldType
fieldTypesMap = Map.fromList [(fieldTypeName fieldType, fieldType) | fieldType <- fieldTypes]

-- | Render a HaskellValue for Haskell.
renderHs :: HaskellValue -> String
renderHs = \case
  HsExpr v -> v
  HsInt v -> show v
  HsBool v -> show v
  HsList vs -> "[" <> intercalate ", " (map renderHs vs) <> "]"

-- | Render a HaskellValue for YAML.
hs2yaml :: String -> HaskellValue -> String
hs2yaml hsType = \case
  HsExpr v ->
    fromMaybe (error $ "Could not render " <> hsType <> " value: " <> v) $
      case hsType `Map.lookup` fieldTypesMap of
        Just FieldTypeEnum {enumOptions} -> v `lookup` enumOptions
        Just FieldTypeADT {adtRender} -> v `lookup` adtRender
        Nothing -> Nothing
  HsInt v -> show v
  HsBool v -> if v then "true" else "false"
  HsList vs ->
    let hsType' =
          case (stripPrefix "[" >=> stripSuffix "]") hsType of
            Just s -> s
            Nothing -> error $ "Not a list type: " <> hsType
     in "[" <> intercalate ", " (map (hs2yaml hsType') vs) <> "]"

{----- Utilities -----}

-- | Like 'unlines', except without a trailing newline.
unlines_ :: [String] -> String
unlines_ = intercalate "\n"

indent :: String -> String
indent = indent' 1

indent' :: Int -> String -> String
indent' n = unlines_ . map (replicate (n * 2) ' ' <>) . lines

quote :: String -> String
quote s = "\"" <> s <> "\""

renderList :: [String] -> String
renderList = \case
  [] -> ""
  [s] -> s
  [s1, s2] -> s1 <> " or " <> s2
  ss -> intercalate ", " (init ss) <> ", or " <> last ss

stripSuffix :: String -> String -> Maybe String
stripSuffix suffix s =
  if suffix `isSuffixOf` s
    then Just $ take (length s - length suffix) s
    else Nothing
