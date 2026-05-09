import Web.Scotty

main :: IO ()
main = scotty 3000 $ do
    get "/health" $ do
        text "ok"