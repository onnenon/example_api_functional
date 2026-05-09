module Domain.Reward where

import Data.Text (Text)
import Domain.User (FamilyId)

newtype RewardId = RewardId Int deriving (Eq, Show)

data Reward = Reward
  { rewardId :: RewardId,
    familyId :: FamilyId,
    title :: Text,
    pointCost :: Int
  }
  deriving (Eq, Show)