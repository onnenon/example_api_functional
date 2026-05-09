let () =
  Dream.run
  @@ Dream.router [ Dream.get "/health" (fun _req -> Dream.respond "ok") ]
