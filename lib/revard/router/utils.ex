defmodule Revard.Router.Utils do
  @moduledoc """
  Some utils for routers
  """

  @doc """
  Redirect connection to given URL
  """
  def redirect(conn, url) do
    conn
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.send_resp(:found, "")
    |> Plug.Conn.halt()
  end

  @doc """
  Return JSON response to given connection
  """
  def json(conn, status, value) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json;charset=UTF-8")
    |> Plug.Conn.send_resp(status, Jason.encode!(value))
    |> Plug.Conn.halt()
  end

  @doc """
  Return error response to given connection
  """
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
