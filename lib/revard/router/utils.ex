defmodule Revard.Router.Utils do
  def json(conn, status, value) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json;charset=UTF-8")
    |> Plug.Conn.send_resp(status, Jason.encode!(value))
    |> Plug.Conn.halt()
  end

  def error(conn, status, message) do
    json(conn, status, %{error: message})
  end

  def unknown_route(conn) do
    error(conn, 404, "Route doesn't exist")
  end
end
