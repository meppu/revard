defmodule Revard.API.Utils do
  def json(conn, status, value) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(value))
    |> Plug.Conn.halt()
  end

  def error(conn, status, message), do: json(conn, status, %{error: message})

  def unknown_route(conn), do: error(conn, 404, "Route doesn't exist")
end
