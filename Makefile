HS_DB_URL := sqlite:./db/haskell.db
ML_DB_URL := sqlite:./db/ocaml.db

.PHONY: db-up db-down db-new db-status hs-build hs-server hs-worker ml-build ml-server ml-worker

db-up:
	dbmate --url $(HS_DB_URL) up
	dbmate --url $(ML_DB_URL) up

db-down:
	dbmate --url $(HS_DB_URL) down
	dbmate --url $(ML_DB_URL) down

db-new:
	dbmate --url $(HS_DB_URL) new $(name)

db-status:
	dbmate --url $(HS_DB_URL) status

hs-build:
	cd haskell && cabal build all

hs-server:
	cd haskell && cabal run example-api

hs-worker:
	cd haskell && cabal run example-api-worker

ml-build:
	cd ocaml && dune build

ml-server:
	cd ocaml && dune exec bin/main.exe

ml-worker:
	cd ocaml && dune exec bin/worker/main.exe

cabal-clean:
	cd haskell && gen-hie > hie.yaml && cabal-fmt example-api.cabal --inplace