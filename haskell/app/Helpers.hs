module Helpers where

import Data.Aeson (ToJSON, object, (.=))
import Data.Text (Text)
import Domain.User (UserError (..))
import Network.HTTP.Types (status201, status204, status404, status409, status422)
import Web.Scotty

respondMaybe :: (ToJSON a) => Maybe a -> ActionM ()
respondMaybe Nothing  = status status404 >> json (object ["error" .= ("not found" :: Text)])
respondMaybe (Just a) = json a

respondFound :: Bool -> ActionM ()
respondFound False = status status404
respondFound True  = status status204

respondCreated :: (ToJSON a) => a -> ActionM ()
respondCreated a = status status201 >> json a

respondUserError :: UserError -> ActionM ()
respondUserError (UniqueViolation field)  = status status409 >> json (object ["error" .= (field <> " already taken" :: Text)])
respondUserError ForeignKeyViolation      = status status422 >> json (object ["error" .= ("referenced resource does not exist" :: Text)])
respondUserError (NotNullViolation field) = status status422 >> json (object ["error" .= (field <> " is required" :: Text)])

respondEither :: (a -> ActionM ()) -> Either UserError a -> ActionM ()
respondEither _ (Left e)  = respondUserError e
respondEither f (Right a) = f a
