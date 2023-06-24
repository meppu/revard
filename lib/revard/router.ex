defmodule Revard.Router do
  @moduledoc """
  Root router for Revard web server
  """

  use Plug.Router

  alias Revard.Router.Utils
  alias Revard.Router.Routes

  plug(:match)
  plug(:dispatch)

  ## Redirect to Revolt server
  get "/" do
    Utils.redirect(conn, Application.get_env(:revard, :invite_url))
  end

  forward("/api", to: Routes.API)
  forward("/gateway", to: Routes.Gateway)
  forward("/card", to: Routes.Card)

  match _ do
    Utils.unknown_route(conn)
  end
end
