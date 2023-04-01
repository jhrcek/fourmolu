{- FOURMOLU_DISABLE -}
{- ***** DO NOT EDIT: This module is autogenerated ***** -}

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module Ormolu.Config.Gen
  ( PrinterOpts (..)
  , CommaStyle (..)
  , FunctionArrowsStyle (..)
  , HaddockPrintStyle (..)
  , HaddockPrintStyleModule (..)
  , ImportExportStyle (..)
  , LetStyle (..)
  , InStyle (..)
  , Unicode (..)
  , SingleConstraintParens (..)
  , ColumnLimit (..)
  , emptyPrinterOpts
  , defaultPrinterOpts
  , defaultPrinterOptsYaml
  , fillMissingPrinterOpts
  , parsePrinterOptsCLI
  , parsePrinterOptsJSON
  , parsePrinterOptType
  )
where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Types as Aeson
import Data.Functor.Identity (Identity)
import Data.Scientific (floatingOrInteger)
import qualified Data.Text as Text
import GHC.Generics (Generic)
import Text.Read (readEither, readMaybe)

-- | Options controlling formatting output.
data PrinterOpts f =
  PrinterOpts
    { -- | Number of spaces per indentation step
      poIndentation :: f Int
    , -- | Styling of arrows in type signatures
      poFunctionArrows :: f FunctionArrowsStyle
    , -- | How to place commas in multi-line lists, records, etc.
      poCommaStyle :: f CommaStyle
    , -- | Styling of import/export lists
      poImportExportStyle :: f ImportExportStyle
    , -- | Whether to full-indent or half-indent 'where' bindings past the preceding body
      poIndentWheres :: f Bool
    , -- | Whether to leave a space before an opening record brace
      poRecordBraceSpace :: f Bool
    , -- | Number of spaces between top-level declarations
      poNewlinesBetweenDecls :: f Int
    , -- | How to print Haddock comments
      poHaddockStyle :: f HaddockPrintStyle
    , -- | How to print module docstring
      poHaddockStyleModule :: f HaddockPrintStyleModule
    , -- | Styling of let blocks
      poLetStyle :: f LetStyle
    , -- | How to align the 'in' keyword with respect to the 'let' keyword
      poInStyle :: f InStyle
    , -- | Output Unicode syntax
      poUnicode :: f Unicode
    , -- | Give the programmer more choice on where to insert blank lines
      poRespectful :: f Bool
    , -- | Whether to put parentheses around a single constraint
      poSingleConstraintParens :: f SingleConstraintParens
    , -- | Max line length for automatic line breaking
      poColumnLimit :: f ColumnLimit
    }
  deriving (Generic)

emptyPrinterOpts :: PrinterOpts Maybe
emptyPrinterOpts =
  PrinterOpts
    { poIndentation = Nothing
    , poFunctionArrows = Nothing
    , poCommaStyle = Nothing
    , poImportExportStyle = Nothing
    , poIndentWheres = Nothing
    , poRecordBraceSpace = Nothing
    , poNewlinesBetweenDecls = Nothing
    , poHaddockStyle = Nothing
    , poHaddockStyleModule = Nothing
    , poLetStyle = Nothing
    , poInStyle = Nothing
    , poUnicode = Nothing
    , poRespectful = Nothing
    , poSingleConstraintParens = Nothing
    , poColumnLimit = Nothing
    }

defaultPrinterOpts :: PrinterOpts Identity
defaultPrinterOpts =
  PrinterOpts
    { poIndentation = pure 4
    , poFunctionArrows = pure TrailingArrows
    , poCommaStyle = pure Leading
    , poImportExportStyle = pure ImportExportDiffFriendly
    , poIndentWheres = pure False
    , poRecordBraceSpace = pure False
    , poNewlinesBetweenDecls = pure 1
    , poHaddockStyle = pure HaddockMultiLine
    , poHaddockStyleModule = pure PrintStyleInherit
    , poLetStyle = pure LetAuto
    , poInStyle = pure InRightAlign
    , poUnicode = pure UnicodeNever
    , poRespectful = pure True
    , poSingleConstraintParens = pure ConstraintAlways
    , poColumnLimit = pure NoLimit
    }

-- | Fill the field values that are 'Nothing' in the first argument
-- with the values of the corresponding fields of the second argument.
fillMissingPrinterOpts ::
  forall f.
  Applicative f =>
  PrinterOpts Maybe ->
  PrinterOpts f ->
  PrinterOpts f
fillMissingPrinterOpts p1 p2 =
  PrinterOpts
    { poIndentation = maybe (poIndentation p2) pure (poIndentation p1)
    , poFunctionArrows = maybe (poFunctionArrows p2) pure (poFunctionArrows p1)
    , poCommaStyle = maybe (poCommaStyle p2) pure (poCommaStyle p1)
    , poImportExportStyle = maybe (poImportExportStyle p2) pure (poImportExportStyle p1)
    , poIndentWheres = maybe (poIndentWheres p2) pure (poIndentWheres p1)
    , poRecordBraceSpace = maybe (poRecordBraceSpace p2) pure (poRecordBraceSpace p1)
    , poNewlinesBetweenDecls = maybe (poNewlinesBetweenDecls p2) pure (poNewlinesBetweenDecls p1)
    , poHaddockStyle = maybe (poHaddockStyle p2) pure (poHaddockStyle p1)
    , poHaddockStyleModule = maybe (poHaddockStyleModule p2) pure (poHaddockStyleModule p1)
    , poLetStyle = maybe (poLetStyle p2) pure (poLetStyle p1)
    , poInStyle = maybe (poInStyle p2) pure (poInStyle p1)
    , poUnicode = maybe (poUnicode p2) pure (poUnicode p1)
    , poRespectful = maybe (poRespectful p2) pure (poRespectful p1)
    , poSingleConstraintParens = maybe (poSingleConstraintParens p2) pure (poSingleConstraintParens p1)
    , poColumnLimit = maybe (poColumnLimit p2) pure (poColumnLimit p1)
    }

parsePrinterOptsCLI ::
  Applicative f =>
  (forall a. PrinterOptsFieldType a => String -> String -> String -> f (Maybe a)) ->
  f (PrinterOpts Maybe)
parsePrinterOptsCLI f =
  pure PrinterOpts
    <*> f
      "indentation"
      "Number of spaces per indentation step (default: 4)"
      "INT"
    <*> f
      "function-arrows"
      "Styling of arrows in type signatures (choices: \"trailing\", \"leading\", or \"leading-args\") (default: trailing)"
      "OPTION"
    <*> f
      "comma-style"
      "How to place commas in multi-line lists, records, etc. (choices: \"leading\" or \"trailing\") (default: leading)"
      "OPTION"
    <*> f
      "import-export-style"
      "Styling of import/export lists (choices: \"leading\", \"trailing\", or \"diff-friendly\") (default: diff-friendly)"
      "OPTION"
    <*> f
      "indent-wheres"
      "Whether to full-indent or half-indent 'where' bindings past the preceding body (default: false)"
      "BOOL"
    <*> f
      "record-brace-space"
      "Whether to leave a space before an opening record brace (default: false)"
      "BOOL"
    <*> f
      "newlines-between-decls"
      "Number of spaces between top-level declarations (default: 1)"
      "INT"
    <*> f
      "haddock-style"
      "How to print Haddock comments (choices: \"single-line\", \"multi-line\", or \"multi-line-compact\") (default: multi-line)"
      "OPTION"
    <*> f
      "haddock-style-module"
      "How to print module docstring (default: same as 'haddock-style')"
      "OPTION"
    <*> f
      "let-style"
      "Styling of let blocks (choices: \"auto\", \"inline\", \"newline\", or \"mixed\") (default: auto)"
      "OPTION"
    <*> f
      "in-style"
      "How to align the 'in' keyword with respect to the 'let' keyword (choices: \"left-align\", \"right-align\", or \"no-space\") (default: right-align)"
      "OPTION"
    <*> f
      "unicode"
      "Output Unicode syntax (choices: \"detect\", \"always\", or \"never\") (default: never)"
      "OPTION"
    <*> f
      "respectful"
      "Give the programmer more choice on where to insert blank lines (default: true)"
      "BOOL"
    <*> f
      "single-constraint-parens"
      "Whether to put parentheses around a single constraint (choices: \"auto\", \"always\", or \"never\") (default: always)"
      "OPTION"
    <*> f
      "column-limit"
      "Max line length for automatic line breaking (default: none)"
      "OPTION"

parsePrinterOptsJSON ::
  Applicative f =>
  (forall a. PrinterOptsFieldType a => String -> f (Maybe a)) ->
  f (PrinterOpts Maybe)
parsePrinterOptsJSON f =
  pure PrinterOpts
    <*> f "indentation"
    <*> f "function-arrows"
    <*> f "comma-style"
    <*> f "import-export-style"
    <*> f "indent-wheres"
    <*> f "record-brace-space"
    <*> f "newlines-between-decls"
    <*> f "haddock-style"
    <*> f "haddock-style-module"
    <*> f "let-style"
    <*> f "in-style"
    <*> f "unicode"
    <*> f "respectful"
    <*> f "single-constraint-parens"
    <*> f "column-limit"

{---------- PrinterOpts field types ----------}

class Aeson.FromJSON a => PrinterOptsFieldType a where
  parsePrinterOptType :: String -> Either String a

instance PrinterOptsFieldType Int where
  parsePrinterOptType = readEither

instance PrinterOptsFieldType Bool where
  parsePrinterOptType s =
    case s of
      "false" -> Right False
      "true" -> Right True
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s,
            "Valid values are: \"false\" or \"true\""
          ]

data CommaStyle
  = Leading
  | Trailing
  deriving (Eq, Show, Enum, Bounded)

data FunctionArrowsStyle
  = TrailingArrows
  | LeadingArrows
  | LeadingArgsArrows
  deriving (Eq, Show, Enum, Bounded)

data HaddockPrintStyle
  = HaddockSingleLine
  | HaddockMultiLine
  | HaddockMultiLineCompact
  deriving (Eq, Show, Enum, Bounded)

data HaddockPrintStyleModule
  = PrintStyleInherit
  | PrintStyleOverride HaddockPrintStyle
  deriving (Eq, Show)

data ImportExportStyle
  = ImportExportLeading
  | ImportExportTrailing
  | ImportExportDiffFriendly
  deriving (Eq, Show, Enum, Bounded)

data LetStyle
  = LetAuto
  | LetInline
  | LetNewline
  | LetMixed
  deriving (Eq, Show, Enum, Bounded)

data InStyle
  = InLeftAlign
  | InRightAlign
  | InNoSpace
  deriving (Eq, Show, Enum, Bounded)

data Unicode
  = UnicodeDetect
  | UnicodeAlways
  | UnicodeNever
  deriving (Eq, Show, Enum, Bounded)

data SingleConstraintParens
  = ConstraintAuto
  | ConstraintAlways
  | ConstraintNever
  deriving (Eq, Show, Enum, Bounded)

data ColumnLimit
  = NoLimit
  | ColumnLimit Int
  deriving (Eq, Show)

instance Aeson.FromJSON CommaStyle where
  parseJSON =
    Aeson.withText "CommaStyle" $ \s ->
      either Aeson.parseFail pure $
        parsePrinterOptType (Text.unpack s)

instance PrinterOptsFieldType CommaStyle where
  parsePrinterOptType s =
    case s of
      "leading" -> Right Leading
      "trailing" -> Right Trailing
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s
          , "Valid values are: \"leading\" or \"trailing\""
          ]

instance Aeson.FromJSON FunctionArrowsStyle where
  parseJSON =
    Aeson.withText "FunctionArrowsStyle" $ \s ->
      either Aeson.parseFail pure $
        parsePrinterOptType (Text.unpack s)

instance PrinterOptsFieldType FunctionArrowsStyle where
  parsePrinterOptType s =
    case s of
      "trailing" -> Right TrailingArrows
      "leading" -> Right LeadingArrows
      "leading-args" -> Right LeadingArgsArrows
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s
          , "Valid values are: \"trailing\", \"leading\", or \"leading-args\""
          ]

instance Aeson.FromJSON HaddockPrintStyle where
  parseJSON =
    Aeson.withText "HaddockPrintStyle" $ \s ->
      either Aeson.parseFail pure $
        parsePrinterOptType (Text.unpack s)

instance PrinterOptsFieldType HaddockPrintStyle where
  parsePrinterOptType s =
    case s of
      "single-line" -> Right HaddockSingleLine
      "multi-line" -> Right HaddockMultiLine
      "multi-line-compact" -> Right HaddockMultiLineCompact
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s
          , "Valid values are: \"single-line\", \"multi-line\", or \"multi-line-compact\""
          ]

instance Aeson.FromJSON HaddockPrintStyleModule where
  parseJSON =
    \v -> case v of
      Aeson.Null -> pure PrintStyleInherit
      Aeson.String "" -> pure PrintStyleInherit
      _ -> PrintStyleOverride <$> Aeson.parseJSON v

instance PrinterOptsFieldType HaddockPrintStyleModule where
  parsePrinterOptType =
    \s -> case s of
      "" -> pure PrintStyleInherit
      _ -> PrintStyleOverride <$> parsePrinterOptType s

instance Aeson.FromJSON ImportExportStyle where
  parseJSON =
    Aeson.withText "ImportExportStyle" $ \s ->
      either Aeson.parseFail pure $
        parsePrinterOptType (Text.unpack s)

instance PrinterOptsFieldType ImportExportStyle where
  parsePrinterOptType s =
    case s of
      "leading" -> Right ImportExportLeading
      "trailing" -> Right ImportExportTrailing
      "diff-friendly" -> Right ImportExportDiffFriendly
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s
          , "Valid values are: \"leading\", \"trailing\", or \"diff-friendly\""
          ]

instance Aeson.FromJSON LetStyle where
  parseJSON =
    Aeson.withText "LetStyle" $ \s ->
      either Aeson.parseFail pure $
        parsePrinterOptType (Text.unpack s)

instance PrinterOptsFieldType LetStyle where
  parsePrinterOptType s =
    case s of
      "auto" -> Right LetAuto
      "inline" -> Right LetInline
      "newline" -> Right LetNewline
      "mixed" -> Right LetMixed
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s
          , "Valid values are: \"auto\", \"inline\", \"newline\", or \"mixed\""
          ]

instance Aeson.FromJSON InStyle where
  parseJSON =
    Aeson.withText "InStyle" $ \s ->
      either Aeson.parseFail pure $
        parsePrinterOptType (Text.unpack s)

instance PrinterOptsFieldType InStyle where
  parsePrinterOptType s =
    case s of
      "left-align" -> Right InLeftAlign
      "right-align" -> Right InRightAlign
      "no-space" -> Right InNoSpace
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s
          , "Valid values are: \"left-align\", \"right-align\", or \"no-space\""
          ]

instance Aeson.FromJSON Unicode where
  parseJSON =
    Aeson.withText "Unicode" $ \s ->
      either Aeson.parseFail pure $
        parsePrinterOptType (Text.unpack s)

instance PrinterOptsFieldType Unicode where
  parsePrinterOptType s =
    case s of
      "detect" -> Right UnicodeDetect
      "always" -> Right UnicodeAlways
      "never" -> Right UnicodeNever
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s
          , "Valid values are: \"detect\", \"always\", or \"never\""
          ]

instance Aeson.FromJSON SingleConstraintParens where
  parseJSON =
    Aeson.withText "SingleConstraintParens" $ \s ->
      either Aeson.parseFail pure $
        parsePrinterOptType (Text.unpack s)

instance PrinterOptsFieldType SingleConstraintParens where
  parsePrinterOptType s =
    case s of
      "auto" -> Right ConstraintAuto
      "always" -> Right ConstraintAlways
      "never" -> Right ConstraintNever
      _ ->
        Left . unlines $
          [ "unknown value: " <> show s
          , "Valid values are: \"auto\", \"always\", or \"never\""
          ]

instance Aeson.FromJSON ColumnLimit where
  parseJSON =
    \case
       Aeson.String "none" ->
         pure NoLimit
       Aeson.Number x
         | Right x' <- (floatingOrInteger x :: Either Double Int) ->
             pure $ ColumnLimit x'
       s ->
         fail . unlines $
           [ "unknown value: " <> show s,
             "Valid values are: \"none\", or an integer"
           ]

instance PrinterOptsFieldType ColumnLimit where
  parsePrinterOptType =
    \s ->
      case s of
        "none" -> Right NoLimit
        _
          | Just someInt <- readMaybe s ->
              Right . ColumnLimit $ someInt
        _ ->
          Left . unlines $
            [ "unknown value: " <> show s,
              "Valid values are: \"none\", or an integer"
            ]

defaultPrinterOptsYaml :: String
defaultPrinterOptsYaml = "indentation: 4 # Number of spaces per indentation step\nfunction-arrows: trailing # Styling of arrows in type signatures (choices: \"trailing\", \"leading\", or \"leading-args\")\ncomma-style: leading # How to place commas in multi-line lists, records, etc. (choices: \"leading\" or \"trailing\")\nimport-export-style: diff-friendly # Styling of import/export lists (choices: \"leading\", \"trailing\", or \"diff-friendly\")\nindent-wheres: false # Whether to full-indent or half-indent 'where' bindings past the preceding body\nrecord-brace-space: false # Whether to leave a space before an opening record brace\nnewlines-between-decls: 1 # Number of spaces between top-level declarations\nhaddock-style: multi-line # How to print Haddock comments (choices: \"single-line\", \"multi-line\", or \"multi-line-compact\")\nhaddock-style-module: null # How to print module docstring\nlet-style: auto # Styling of let blocks (choices: \"auto\", \"inline\", \"newline\", or \"mixed\")\nin-style: right-align # How to align the 'in' keyword with respect to the 'let' keyword (choices: \"left-align\", \"right-align\", or \"no-space\")\nunicode: never # Output Unicode syntax (choices: \"detect\", \"always\", or \"never\")\nrespectful: true # Give the programmer more choice on where to insert blank lines\nfixities: [] # Fixity information for operators\nsingle-constraint-parens: always # Whether to put parentheses around a single constraint (choices: \"auto\", \"always\", or \"never\")\ncolumn-limit: none # Max line length for automatic line breaking\n"
