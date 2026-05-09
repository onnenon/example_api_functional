module Repo.User where

import Data.Functor ((<&>))
import Data.Maybe (fromMaybe)
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

createUser :: Connection -> NewUser -> IO User
createUser conn u = do
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

updateUser :: Connection -> UserId -> NewUser -> IO (Maybe User)
updateUser conn uid@(UserId i) u = do
  execute
    conn
    "UPDATE users \
    \SET family_id=?, username=?, display_name=?, avatar=?, birthday=?, role=?, points=? \
    \WHERE id=?"
    (toRow u <> toRow (Only i))
  getUser conn uid

patchUser :: Connection -> UserId -> PatchUser -> IO (Maybe User)
patchUser conn uid p = do
  current <- getUser conn uid
  case current of
    Nothing -> pure Nothing
    Just u -> updateUser conn uid (applyPatch u p)

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