-- migrate:up
CREATE TABLE users (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  family_id    INTEGER NOT NULL,
  username     TEXT    NOT NULL UNIQUE,
  display_name TEXT    NOT NULL,
  avatar       TEXT,
  birthday     TEXT,
  role         TEXT    NOT NULL CHECK (role IN ('parent', 'child'))
);

-- migrate:down
DROP TABLE users;
