defmodule Revard.Router.Routes.Card do
  @moduledoc """
  Router for card
  """

  use Plug.Router

  require Logger

  alias Revard.Router.Utils
  alias Revard.Storage
  alias Revard.Card.Renderer

  plug(:match)
  plug(:dispatch)

  ## Render card and return svg
  get "/:id" do
    %Plug.Conn{params: %{"id" => user_id}} = conn
    conn = %Plug.Conn{query_params: options} = fetch_query_params(conn)

    Logger.debug("Rendering #{user_id}'s information (http)")

    case Storage.Users.get(user_id, :all) do
      %{user: %{"_id" => ^user_id}} = user_data ->
        conn
        |> put_resp_header("content-type", "image/svg+xml;charset=UTF-8")
        |> put_resp_header(
          "content-security-policy",
          "default-src 'none'; img-src * data:; style-src 'unsafe-inline'"
        )
        |> send_resp(200, Renderer.render(user_data, options))

      nil ->
        Utils.user_not_found(conn)
    end
  end

  match _ do
    Utils.unknown_route(conn)
  end
end
