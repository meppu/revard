defmodule Revard.Router do
  use Plug.Router

  alias Revard.Router.Utils
  alias Revard.Router.Routes

  plug(:match)
  plug(:dispatch)

  forward("/api", to: Routes.API)
  forward("/gateway", to: Routes.Gateway)

  match _ do
    Utils.unknown_route(conn)
  end
end
