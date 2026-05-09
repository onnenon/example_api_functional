module Domain.PointTransaction where

import Data.Text (Text)
import Data.Time (UTCTime)
import Domain.Reward (RewardId)
import Domain.Task (TaskId)
import Domain.User (UserId)

newtype TransactionId = TransactionId Int deriving (Show, Eq)

data TransactionReason
  = TaskCompletion TaskId
  | RewardRedeption RewardId
  | ManualAdjustment Text
  deriving (Show, Eq)

data PointTransaction = PointTransaction
  { trasactionId :: TransactionId,
    userId :: UserId,
    amount :: Int,
    reason :: TransactionReason,
    createdAt :: UTCTime
  }
