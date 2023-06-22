defmodule Revard.Router.Routes.Gateway do
  use Plug.Router

  alias Revard.Router.Utils

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> WebSockAdapter.upgrade(Revard.Gateway.Listener, [], max_frame_size: 8192, timeout: 60_000)
    |> halt()
  end

  match _ do
    Utils.unknown_route(conn)
  end
end
