defmodule Revard.API.Users do
  use Plug.Router

  require Logger

  alias Revard.Router.Utils
  alias Revard.Storage

  plug(:match)
  plug(:dispatch)

  get "/:id" do
    %Plug.Conn{params: %{"id" => user_id}} = conn
    Logger.debug("Getting #{user_id}'s information (http)")

    case Storage.Users.get(user_id) do
      %{"_id" => ^user_id} = response ->
        Utils.json(conn, 200, response)

      nil ->
        Utils.user_not_found(conn)
    end
  end

  get "/:id/avatar" do
    %Plug.Conn{params: %{"id" => user_id}} = conn
    Logger.debug("Redirecting to #{user_id}'s avatar (http)")

    case Storage.Users.get(user_id) do
      %{"_id" => ^user_id, "avatar" => %{"_id" => avatar_id}} ->
        url = Application.get_env(:revard, :autumn_url) <> "/avatars/" <> avatar_id
        Utils.redirect(conn, url)

      _ ->
        Utils.user_not_found(conn)
    end
  end

  get "/:id/background" do
    %Plug.Conn{params: %{"id" => user_id}} = conn
    Logger.debug("Redirecting to #{user_id}'s background (http)")

    case Storage.Users.get(user_id) do
      %{"_id" => ^user_id, "profile" => %{"background" => %{"_id" => background_id}}} ->
        url = Application.get_env(:revard, :autumn_url) <> "/backgrounds/" <> background_id
        Utils.redirect(conn, url)

      _ ->
        Utils.user_not_found(conn)
    end
  end

  match _ do
    Utils.unknown_route(conn)
  end
end
