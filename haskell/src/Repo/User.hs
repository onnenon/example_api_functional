module Repo.User where

import Control.Exception (try, throwIO)
import Data.Functor ((<&>))
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Text qualified as T
import Database.SQLite.Simple
import Domain.User

listUsers :: Connection -> IO [User]
listUsers conn =
  query_
    conn
    "SELECT id, family_id, username, display_name, avatar, birthday, role, points \
    \FROM users"

getUser :: Connection -> UserId -> IO (Maybe User)
getUser conn (UserId uid) = do
  rows <-
    query
      conn
      "SELECT id, family_id, username, display_name, avatar, birthday, role, points \
      \FROM users WHERE id = ?"
      (Only uid)
  pure $ case rows of
    [u] -> Just u
    _ -> Nothing

createUser :: Connection -> NewUser -> IO (Either UserError User)
createUser conn u = runWithConstraints $ do
  execute
    conn
    "INSERT INTO users (family_id, username, display_name, avatar, birthday, role, points) \
    \VALUES (?, ?, ?, ?, ?, ?, ?)"
    u
  uid <- lastInsertRowId conn
  getUser conn (UserId (fromIntegral uid)) >>= orFail
  where
    orFail (Just user) = pure user
    orFail Nothing = fail "createUser: inserted row not found"

updateUser :: Connection -> UserId -> NewUser -> IO (Either UserError (Maybe User))
updateUser conn uid@(UserId i) u = runWithConstraints $ do
  execute
    conn
    "UPDATE users \
    \SET family_id=?, username=?, display_name=?, avatar=?, birthday=?, role=?, points=? \
    \WHERE id=?"
    (toRow u <> toRow (Only i))
  getUser conn uid

patchUser :: Connection -> UserId -> PatchUser -> IO (Either UserError (Maybe User))
patchUser conn uid p = do
  current <- getUser conn uid
  case current of
    Nothing -> pure (Right Nothing)
    Just u  -> updateUser conn uid (applyPatch u p)

runWithConstraints :: IO a -> IO (Either UserError a)
runWithConstraints action = do
  result <- try @SQLError action
  case result of
    Right a -> pure (Right a)
    Left (SQLError ErrorConstraint details _) -> pure (Left (parseConstraint details))
    Left e -> throwIO e

parseConstraint :: Text -> UserError
parseConstraint details
  | Just rest <- T.stripPrefix "UNIQUE constraint failed: "    details = UniqueViolation (afterDot rest)
  | Just rest <- T.stripPrefix "NOT NULL constraint failed: "  details = NotNullViolation (afterDot rest)
  | "FOREIGN KEY constraint failed" `T.isPrefixOf` details              = ForeignKeyViolation
  | otherwise                                                           = UniqueViolation details

afterDot :: Text -> Text
afterDot = snd . T.breakOnEnd "."

applyPatch :: User -> PatchUser -> NewUser
applyPatch u p =
  NewUser
    { familyId = fromMaybe u.familyId p.familyId,
      username = fromMaybe u.username p.username,
      displayName = fromMaybe u.displayName p.displayName,
      avatar = fromMaybe u.avatar p.avatar,
      birthday = fromMaybe u.birthday p.birthday,
      role = fromMaybe u.role p.role
    }

deleteUser :: Connection -> UserId -> IO Bool
deleteUser conn (UserId uid) = do
  execute conn "DELETE FROM users WHERE id=?" (Only uid)
  changes conn <&> (> 0)