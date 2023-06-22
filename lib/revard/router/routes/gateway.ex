defmodule Revard.Router.Routes.Gateway do
  @moduledoc """
  Router for gateway
  """

  use Plug.Router

  alias Revard.Router.Utils

  plug(:match)
  plug(:dispatch)

  ## Upgrade to websocket connection
  get "/" do
    conn
    |> WebSockAdapter.upgrade(Revard.Gateway.Listener, [], max_frame_size: 8192, timeout: 60_000)
    |> halt()
  end

  match _ do
    Utils.unknown_route(conn)
  end
end
