let open_db path =
  let db = Sqlite3.db_open path in
  let exec sql =
    match Sqlite3.exec db sql with
    | Sqlite3.Rc.OK -> ()
    | rc -> failwith ("DB setup failed: " ^ Sqlite3.Rc.to_string rc)
  in
  exec "PRAGMA journal_mode=WAL";
  exec "PRAGMA foreign_keys=ON";
  db
