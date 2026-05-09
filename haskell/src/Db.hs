module Db where

import Database.SQLite.Simple

openDb :: FilePath -> IO Connection
openDb path = do
  conn <- open path
  execute_ conn "PRAGMA journal_mode=WAL"
  execute_ conn "PRAGMA foreign_keys=ON"
  pure conn
