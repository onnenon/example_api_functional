import Control.Exception (SomeException)
import Data.Aeson (object, (.=))
import Data.Text (Text)
import Db (openDb)
import Network.HTTP.Types (status500)
import Routes.User (userRoutes)
import Web.Scotty

main :: IO ()
main = do
  conn <- openDb "../db/haskell.db"
  scotty 3000 $ do
    defaultHandler $ Handler handleException
    get "/health" $
      text "ok"
    userRoutes conn

handleException :: SomeException -> ActionM ()
handleException _ =
  status status500 >> json (object ["error" .= ("internal server error" :: Text)])
