module Domain.User where

import Data.Aeson
  ( FromJSON (..),
    Options,
    ToJSON (..),
    defaultOptions,
    fieldLabelModifier,
    genericParseJSON,
    genericToJSON,
    withText,
  )
import Data.Aeson.Types (camelTo2)
import Data.Text (Text)
import Data.Time (Day)
import Database.SQLite.Simple (FromRow (..), ToRow (..), field)
import Database.SQLite.Simple.FromField
  ( FromField (..),
    ResultError (..),
    returnError,
  )
import Database.SQLite.Simple.ToField (toField)
import GHC.Generics (Generic)

newtype UserId = UserId Int deriving (Show, Eq, ToJSON)

newtype FamilyId = FamilyId Int deriving (Show, Eq, FromJSON, ToJSON)

data Role
  = Parent
  | Child
  deriving (Show, Eq)

roleToText :: Role -> Text
roleToText Parent = "parent"
roleToText Child = "child"

roleFromText :: Text -> Maybe Role
roleFromText "parent" = Just Parent
roleFromText "child" = Just Child
roleFromText _ = Nothing

data User = User
  { id :: UserId,
    familyId :: FamilyId,
    username :: Text,
    displayName :: Text,
    avatar :: Maybe Text,
    birthday :: Maybe Day,
    role :: Role
  }
  deriving (Show, Eq, Generic)

data NewUser = NewUser
  { familyId :: FamilyId,
    username :: Text,
    displayName :: Text,
    avatar :: Maybe Text,
    birthday :: Maybe Day,
    role :: Role
  }
  deriving (Show, Eq, Generic)

data PatchUser = PatchUser
  { familyId :: Maybe FamilyId,
    username :: Maybe Text,
    displayName :: Maybe Text,
    avatar :: Maybe (Maybe Text),
    birthday :: Maybe (Maybe Day),
    role :: Maybe Role
  }
  deriving (Show, Eq, Generic)

data UserError
  = UniqueViolation Text
  | ForeignKeyViolation
  | NotNullViolation Text
  deriving (Show, Eq)

instance FromJSON Role where
  parseJSON = withText "Role" parse
    where
      parse t = case roleFromText t of
        Just r -> pure r
        Nothing -> fail "role must be 'parent' or 'child'"

myOptions :: Options
myOptions = defaultOptions {fieldLabelModifier = camelTo2 '_'}

instance ToJSON Role where
  toJSON = toJSON . roleToText

instance ToJSON User where
  toJSON = genericToJSON myOptions

instance FromJSON NewUser where
  parseJSON = genericParseJSON myOptions

instance FromJSON PatchUser where
  parseJSON = genericParseJSON myOptions

instance FromField Role where
  fromField f = do
    text <- fromField f
    case roleFromText text of
      Just r -> pure r
      Nothing -> returnError ConversionFailed f "unknown role"

instance FromRow User where
  fromRow = do
    uid <- UserId <$> field
    fid <- FamilyId <$> field
    username <- field
    displayName <- field
    avatar <- field
    birthday <- field
    role <- field
    pure User {id = uid, familyId = fid, username, displayName, avatar, birthday, role}

instance ToRow NewUser where
  toRow u =
    [ toField $ let FamilyId f = u.familyId in f,
      toField u.username,
      toField u.displayName,
      toField u.avatar,
      toField u.birthday,
      toField $ roleToText u.role
    ]