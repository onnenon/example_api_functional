module Repo.User where

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