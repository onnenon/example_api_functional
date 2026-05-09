module Domain.User where

import Data.Text (Text)
import Data.Time (Day)

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
