import Db (openDb)
import Helpers (handleException)
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
