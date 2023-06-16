defmodule Revard.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  forward("/api", to: Revard.API.Router)

  match _ do
    send_resp(conn, 404, <<>>)
  end
end
