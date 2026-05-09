# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Side-by-side comparison of Haskell and OCaml for building a web backend. The domain is a kids reward app: children are assigned tasks, complete them for points, and redeem points for rewards.

**Planned domain model:** `Child`, `Task` (assigned to a child, has a point value and status), `Reward` (has a point cost), `Redemption`, and a SQLite-backed job queue for async work like awarding points on task approval.

## Projects

Two independent projects live in `haskell/` and `ocaml/`. Each has a web server and a worker process.

| | Haskell | OCaml |
|---|---|---|
| Web framework | Scotty (port 3000) | Dream / Lwt (port 8080) |
| Worker concurrency | `async` | Eio |
| Database | sqlite-simple | sqlite3 |
| JSON | aeson | yojson |

## Haskell

All commands run from `haskell/`.

```bash
cabal build all
cabal run example-api           # web server
cabal run example-api-worker    # worker process
```

**Structure:**
- `src/` — shared library (`lib:example-api`). Add modules here and list them under `exposed-modules` in the cabal file.
- `app/Main.hs` — Scotty web server
- `worker/Main.hs` — async worker

**Notes:**
- `common defaults` in `example-api.cabal` sets `GHC2021`, `OverloadedStrings`, and `-Wall -threaded` for all targets. New targets should `import: defaults`.
- `hie.yaml` maps source paths to cabal components — required for HLS to resolve modules correctly. Regenerate it with `gen-hie > hie.yaml` (requires `implicit-hie`) when adding new components.

## OCaml

All commands run from `ocaml/`.

```bash
opam install . --deps-only      # install dependencies (run once per switch)
dune build
dune exec bin/main.exe          # web server
dune exec bin/worker/main.exe   # worker process
dune fmt                        # format all OCaml files (ocamlformat)
```

**Structure:**
- `lib/` — shared library (`example_api`). Add modules here; they're available to both executables.
- `bin/main.ml` — Dream web server (Lwt-based)
- `bin/worker/main.ml` — Eio worker

**Notes:**
- The server uses Dream/Lwt and the worker uses Eio. These runtimes don't compose, so they are separate executables communicating via the SQLite jobs table — not a single binary.
- `eio_main` is a library within the `eio` opam package, not its own package. List only `eio` in `dune-project (depends ...)`, but `eio eio_main` in dune `(libraries ...)` stanzas.
- `ocamlformat` is configured with `profile = default` in `.ocamlformat`.

## Job Queue Pattern

Both workers use a `jobs` table in SQLite. The worker polls on an interval, claims `pending` jobs, processes them, and marks them `done`. Point-awarding on task approval is the primary job type.
