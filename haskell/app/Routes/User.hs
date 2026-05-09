module Routes.User (userRoutes) where

import Database.SQLite.Simple (Connection)
import Domain.User
import Helpers
import Network.HTTP.Types (status201)
import Repo.User qualified as UserRepo
import Web.Scotty

userRoutes :: Connection -> ScottyM ()
userRoutes conn = do
  get "/users" $
    liftIO (UserRepo.listUsers conn) >>= json

  get "/users/:id" $ do
    uid <- UserId <$> captureParam "id"
    liftIO (UserRepo.getUser conn uid) >>= respondMaybe

  post "/users" $ do
    nu <- jsonData
    u <- liftIO $ UserRepo.createUser conn nu
    status status201 >> json u

  put "/users/:id" $ do
    uid <- UserId <$> captureParam "id"
    nu <- jsonData
    liftIO (UserRepo.updateUser conn uid nu) >>= respondMaybe

  patch "/users/:id" $ do
    uid <- UserId <$> captureParam "id"
    p <- jsonData
    liftIO (UserRepo.patchUser conn uid p) >>= respondMaybe

  delete "/users/:id" $ do
    uid <- UserId <$> captureParam "id"
    liftIO (UserRepo.deleteUser conn uid) >>= respondFound
