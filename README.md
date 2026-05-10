# Example API: Haskell vs OCaml

A side-by-side comparison of Haskell and OCaml for building a functional web backend. The domain is a family rewards app: children are assigned tasks, complete them for points, and redeem points for rewards.

## Projects

Two independent projects in `haskell/` and `ocaml/`, each with a web server and a worker process.

| | Haskell | OCaml |
|---|---|---|
| Web framework | Scotty | Dream / Lwt |
| Port | 3000 | 8080 |
| Worker concurrency | `async` | Eio |
| Database | sqlite-simple | sqlite3 |
| JSON | aeson | yojson + ppx_yojson_conv |

## Quick Start

```bash
# Run both servers
make hs-server    # http://localhost:3000
make ml-server    # http://localhost:8080

# Run both workers
make hs-worker
make ml-worker

# Database
make db-up        # run migrations
make db-status    # check migration state
make db-down      # rollback
```

## Haskell

```bash
cd haskell/
cabal build all
cabal run example-api           # web server
cabal run example-api-worker    # worker
```

**Structure:**

```
haskell/
├── app/
│   ├── Main.hs           # Scotty server entry
│   ├── Helpers.hs        # Response helpers, error handling
│   └── Routes/
│       └── User.hs       # User CRUD endpoints
├── src/                  # Shared library (lib:example-api)
│   ├── Db.hs
│   ├── Domain/
│   │   ├── User.hs
│   │   ├── Task.hs
│   │   ├── Reward.hs
│   │   └── PointTransaction.hs
│   └── Repo/
│       └── User.hs
└── worker/
    └── Main.hs
```

## OCaml

```bash
cd ocaml/
opam install . --deps-only    # once per switch
dune build
dune exec bin/main.exe        # web server
dune exec bin/worker/main.exe # worker
dune fmt                      # format
```

**Structure:**

```
ocaml/
├── lib/                  # Shared library (example_api)
│   ├── db.ml
│   ├── domain/
│   │   ├── user.ml
│   │   ├── task.ml
│   │   ├── reward.ml
│   │   └── point_transaction.ml
│   └── repo/
│       └── user.ml
├── bin/
│   ├── main.ml           # Dream server entry
│   └── worker/
│       └── main.ml       # Eio worker entry
└── test/
    └── test_example_api.ml
```

## Domain Model

- **User** — a family member with a `parent` or `child` role
- **Task** — assigned to a child, has a point value and a status (`pending → completed → approved/rejected`)
- **Reward** — redeemable item with a point cost
- **PointTransaction** — audit trail of point changes (task completion, reward redemption, manual adjustment)
- **Job** — async work queue entry (e.g., award points when a task is approved)

## API Endpoints (Haskell — implemented)

```
GET    /health
GET    /users
GET    /users/:id
POST   /users
PUT    /users/:id
PATCH  /users/:id
DELETE /users/:id
```

## Database

Both projects share a schema defined in `db/schema.sql` and managed with [dbmate](https://github.com/amacneil/dbmate). Each runtime uses its own SQLite file (`db/haskell.db`, `db/ocaml.db`).

## Implementation Status

| Feature | Haskell | OCaml |
|---|---|---|
| Health endpoint | Done | Done |
| User CRUD | Done | Pending |
| Task CRUD | Pending | Pending |
| Reward CRUD | Pending | Pending |
| Point transactions | Pending | Pending |
| Job queue / worker | Pending | Pending |
