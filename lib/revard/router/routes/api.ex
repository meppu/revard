defmodule Revard.Router.Routes.API do
  use Plug.Router

  alias Revard.API
  alias Revard.Router.Utils

  plug(:match)
  plug(CORSPlug)
  plug(:dispatch)

  forward("/users", to: API.Users)

  match _ do
    Utils.unknown_route(conn)
  end
end
