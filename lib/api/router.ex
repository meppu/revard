defmodule Revard.API.Router do
  use Plug.Router

  alias Revard.API.Routes
  alias Revard.API.Utils

  plug(:match)

  plug(CORSPlug)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  forward("/users", to: Routes.Users)

  match _ do
    Utils.unknown_route(conn)
  end
end
