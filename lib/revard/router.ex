defmodule Revard.Router do
  @moduledoc """
  Root router for Revard web server
  """

  use Plug.Router

  alias Revard.Router.{Utils, Routes}

  plug :match
  plug :dispatch

  ## Redirect to README
  get "/" do
    Utils.redirect(conn, "https://github.com/meppu/revard/blob/main/README.md")
  end

  ## Redirect to Revolt server
  get "/invite" do
    Utils.redirect(conn, Application.get_env(:revard, :invite_url))
  end

  forward "/api", to: Routes.API
  forward "/gateway", to: Routes.Gateway
  forward "/card", to: Routes.Card

  match _ do
    Utils.unknown_route(conn)
  end
end
