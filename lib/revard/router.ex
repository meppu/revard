defmodule Revard.Router do
  use Plug.Router

  alias Revard.Router.Utils
  alias Revard.Router.Routes

  plug(:match)
  plug(:dispatch)

  get "/" do
    Utils.redirect(conn, Application.get_env(:revard, :invite_url))
  end

  forward("/api", to: Routes.API)
  forward("/gateway", to: Routes.Gateway)

  match _ do
    Utils.unknown_route(conn)
  end
end
