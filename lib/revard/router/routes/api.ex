defmodule Revard.Router.Routes.API do
  @moduledoc """
  Router for /users
  """

  use Plug.Router

  alias Revard.API
  alias Revard.Router.Utils

  plug :match

  plug Corsica,
    origins: "*",
    max_age: 600,
    allow_methods: :all,
    allow_headers: :all

  plug :dispatch

  forward "/users", to: API.Users

  match _ do
    Utils.unknown_route(conn)
  end
end
