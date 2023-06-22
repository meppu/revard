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

    # Load from cache if exists
    # Otherwise just add current value to cache
    response =
      case Storage.Cache.get(user_id) do
        [{^user_id, value} | _other] ->
          value

        _ ->
          value =
            user_id
            |> Storage.Users.get()
            |> List.first()

          Storage.Cache.set(user_id, value)
          value
      end

    if response == nil do
      Utils.error(conn, 404, "Requested user not found")
    else
      Utils.json(conn, 200, response)
    end
  end

  match _ do
    Utils.unknown_route(conn)
  end
end
