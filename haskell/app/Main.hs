import Data.Aeson (ToJSON, object, (.=))
import Data.Text (Text)
import Db (openDb)
import Domain.User
import Network.HTTP.Types (status201, status204, status404)
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

respondMaybe :: (ToJSON a) => Maybe a -> ActionM ()
respondMaybe Nothing = status status404 >> json (object ["error" .= ("not found" :: Text)])
respondMaybe (Just u) = json u

respondFound :: Bool -> ActionM ()
respondFound False = status status404
respondFound True = status status204