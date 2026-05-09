import Db (openDb)
import Routes.User (userRoutes)
import Web.Scotty

main :: IO ()
main = do
  conn <- openDb "../db/haskell.db"
  scotty 3000 $ do
    get "/health" $
      text "ok"
    userRoutes conn

