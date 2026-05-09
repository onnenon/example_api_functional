import Db (openDb)
import Domain.User
import Helpers
import Network.HTTP.Types (status201)
import Repo.User qualified as UserRepo
import Web.Scotty

main :: IO ()
main = do
  conn <- openDb "../db/haskell.db"
  scotty 3000 $ do
    get "/health" $
      text "ok"

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

    delete "/users/:id" $ do
      uid <- UserId <$> captureParam "id"
      liftIO (UserRepo.deleteUser conn uid) >>= respondFound

