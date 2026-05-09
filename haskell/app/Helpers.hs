module Helpers where

import Data.Aeson (ToJSON, object, (.=))
import Data.Text (Text)
import Network.HTTP.Types (status204, status404)
import Web.Scotty

respondMaybe :: (ToJSON a) => Maybe a -> ActionM ()
respondMaybe Nothing  = status status404 >> json (object ["error" .= ("not found" :: Text)])
respondMaybe (Just u) = json u

respondFound :: Bool -> ActionM ()
respondFound False = status status404
respondFound True  = status status204
