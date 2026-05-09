# Haskell Project

## Commands

```bash
cabal build all
cabal run example-api           # web server (port 3000)
cabal run example-api-worker    # worker process
```

Or use the root Makefile: `make hs-build`, `make hs-server`, `make hs-worker`.

## Extensions (applied to all targets via `common defaults`)

- `GHC2021`
- `DuplicateRecordFields` + `NoFieldSelectors` + `OverloadedRecordDot` — record fields are accessed via dot syntax (`user.userId`), not as functions
- `OverloadedStrings`

## Structure

- `src/` — shared library (`lib:example-api`)
  - `Db.hs` — open SQLite connection (WAL mode); no schema management, migrations are external
  - `Domain/` — pure domain types + their JSON and DB typeclass instances
  - `Repo/` — one module per domain type, CRUD functions taking a `Connection`
- `app/Main.hs` — Scotty web server, opens DB and wires routes
- `worker/Main.hs` — async worker, polls the jobs table

## Conventions

- Domain types and their `FromRow`/`ToRow`/`FromJSON`/`ToJSON` instances live together in `Domain/`.
- Each domain type has a companion `NewUser`-style type (no ID) used for POST/PUT request bodies and INSERT parameters.
- `ToRow` is implemented on the `New*` type; `FromRow` on the full type.
- The DB file path is `../db/haskell.db` relative to the project root. Migrations are managed by dbmate from the root `Makefile`.
- When adding new modules, list them under `exposed-modules` in `example-api.cabal` and regenerate `hie.yaml` with `gen-hie > hie.yaml`.
