defmodule Revard.Router.Utils do
  def redirect(conn, url) do
    conn
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.send_resp(:found, "")
    |> Plug.Conn.halt()
  end

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
    error(conn, 404, "Requested path doesn't exist")
  end

  def user_not_found(conn) do
    error(conn, 404, "Requested data for user not found")
  end
end
