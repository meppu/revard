defmodule Revard.API.Users do
  @moduledoc """
  User routes
  """

  use Plug.Router

  require Logger

  alias Revard.Router.Utils
  alias Revard.Storage.Users

  plug(:match)
  plug(:dispatch)

  ## Returns user's data
  get "/:id" do
    %Plug.Conn{params: %{"id" => user_id}} = conn
    Logger.debug("Getting #{user_id}'s information (http)")

    case Users.get(user_id, :user) do
      %{"_id" => ^user_id} = response ->
        Utils.json(conn, 200, response)

      _ ->
        Utils.user_not_found(conn)
    end
  end

  ## Redirects to user's avatar url
  get "/:id/avatar" do
    %Plug.Conn{params: %{"id" => user_id}} = conn
    Logger.debug("Redirecting to #{user_id}'s avatar (http)")

    case Users.get(user_id, :user) do
      %{"_id" => ^user_id} = user_data ->
        url = Users.Utils.get_user_avatar(user_data, {:url, nil})
        Utils.redirect(conn, url)

      _ ->
        Utils.user_not_found(conn)
    end
  end

  ## Redirects to user's background url
  get "/:id/background" do
    %Plug.Conn{params: %{"id" => user_id}} = conn
    Logger.debug("Redirecting to #{user_id}'s background (http)")

    case Users.get(user_id, :user) do
      %{"_id" => ^user_id, "profile" => %{"background" => %{"_id" => _background_id}}} = user_data ->
        url = Users.Utils.get_user_background(user_data, {:url, nil})
        Utils.redirect(conn, url)

      _ ->
        Utils.user_not_found(conn)
    end
  end

  match _ do
    Utils.unknown_route(conn)
  end
end
