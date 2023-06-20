defmodule Revard.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/gateway" do
    conn
    |> WebSockAdapter.upgrade(Revard.Socket.Listener, [], max_frame_size: 8192, timeout: 60_000)
    |> halt()
  end

  forward("/api", to: Revard.API.Router)

  match _ do
    send_resp(conn, 404, <<>>)
  end
end
