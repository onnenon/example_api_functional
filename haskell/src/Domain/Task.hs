module Domain.Task where

import Data.Text (Text)
import Domain.User (FamilyId, UserId)

newtype TaskId = TaskId Int deriving (Show, Eq)

data TaskStatus = Pending | Completed | Approved | Rejected deriving (Eq, Show)

data Task = Task
  { taskId :: TaskId,
    familyId :: FamilyId,
    assignedTo :: UserId,
    title :: Text,
    pointValue :: Int,
    status :: TaskStatus
  }
  deriving (Eq, Show)