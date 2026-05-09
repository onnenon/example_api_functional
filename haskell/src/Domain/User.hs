module Domain.User where

import Data.Aeson (FromJSON (..), ToJSON (..), object, withObject, (.:), (.:?), (.=))
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Time (Day)
import Database.SQLite.Simple (FromRow (..), ToRow (..), field)
import Database.SQLite.Simple.FromRow (RowParser)
import Database.SQLite.Simple.ToField (toField)

newtype UserId = UserId Int deriving (Show, Eq)

newtype FamilyId = FamilyId Int deriving (Show, Eq)

data Role
  = Parent
  | Child {points :: Int}
  deriving (Show, Eq)

data User = User
  { userId :: UserId,
    familyId :: FamilyId,
    username :: Text,
    displayName :: Text,
    avatar :: Maybe Text,
    birthday :: Maybe Day,
    role :: Role
  }
  deriving (Show, Eq)

data NewUser = NewUser
  { familyId :: FamilyId,
    username :: Text,
    displayName :: Text,
    avatar :: Maybe Text,
    birthday :: Maybe Day,
    role :: Role
  }
  deriving (Show, Eq)

data PatchUser = PatchUser
  { familyId :: Maybe FamilyId,
    username :: Maybe Text,
    displayName :: Maybe Text,
    avatar :: Maybe (Maybe Text),
    birthday :: Maybe (Maybe Day),
    role :: Maybe Role
  }
  deriving (Show, Eq)

instance ToJSON User where
  toJSON u =
    object
      [ "id" .= let UserId i = u.userId in i,
        "family_id" .= let FamilyId f = u.familyId in f,
        "username" .= u.username,
        "display_name" .= u.displayName,
        "avatar" .= u.avatar,
        "birthday" .= u.birthday,
        "role" .= roleText u.role,
        "points" .= rolePoints u.role
      ]
    where
      roleText Parent = "parent" :: Text
      roleText (Child _) = "child"
      rolePoints Parent = Nothing :: Maybe Int
      rolePoints (Child {points}) = Just points

instance FromJSON NewUser where
  parseJSON = withObject "NewUser" $ \o -> do
    familyId <- FamilyId <$> o .: "family_id"
    username <- o .: "username"
    displayName <- o .: "display_name"
    avatar <- o .:? "avatar"
    birthday <- o .:? "birthday"
    roleText <- o .: "role"
    points <- o .:? "points"
    case points of
      Just p | p < 0 -> fail "points must not be negative"
      _ -> pure ()
    role <- case (roleText :: Text) of
      "parent" -> pure Parent
      "child" -> pure $ Child {points = fromMaybe 0 points}
      _ -> fail "role must be 'parent' or 'child'"
    pure NewUser {familyId, username, displayName, avatar, birthday, role}

instance FromJSON PatchUser where
  parseJSON = withObject "PatchUser" $ \o -> do
    familyId <- fmap FamilyId <$> o .:? "family_id"
    username <- o .:? "username"
    displayName <- o .:? "display_name"
    avatar <- o .:? "avatar"
    birthday <- o .:? "birthday"
    roleText <- o .:? "role"
    points <- o .:? "points"
    role <- case (roleText :: Maybe Text) of
      Nothing -> pure Nothing
      Just "parent" -> pure $ Just Parent
      Just "child" -> pure $ Just (Child {points = fromMaybe 0 points})
      Just _ -> fail "role must be 'parent' or 'child'"
    pure PatchUser {familyId, username, displayName, avatar, birthday, role}

instance FromRow User where
  fromRow = do
    uid <- UserId <$> field
    fid <- FamilyId <$> field
    username <- field
    displayName <- field
    avatar <- field
    birthday <- field
    roleText <- field :: RowParser Text
    points <- field :: RowParser (Maybe Int)
    let role = toRole roleText points
    pure User {userId = uid, familyId = fid, username, displayName, avatar, birthday, role}
    where
      toRole :: Text -> Maybe Int -> Role
      toRole "child" pts = Child {points = fromMaybe 0 pts}
      toRole _ _ = Parent

instance ToRow NewUser where
  toRow u =
    [ toField $ let FamilyId f = u.familyId in f,
      toField u.username,
      toField u.displayName,
      toField u.avatar,
      toField u.birthday,
      toField $ roleText u.role,
      toField $ rolePoints u.role
    ]
    where
      roleText Parent = "parent" :: Text
      roleText (Child _) = "child"
      rolePoints Parent = Nothing :: Maybe Int
      rolePoints (Child {points}) = Just points
