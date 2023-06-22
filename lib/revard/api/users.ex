defmodule Revard.API.Users do
  use Plug.Router

  require Logger

  alias Revard.Router.Utils

  plug(:match)
  plug(:dispatch)

  get "/:id" do
    %Plug.Conn{params: %{"id" => user_id}} = conn

    Logger.debug("Getting #{user_id}'s information (http)")

    # Load from cache if exists
    # Otherwise just add current value to cache
    response =
      case :ets.lookup(:cache, user_id) do
        [{^user_id, value} | _other] when is_map(value) ->
          value

        _ ->
          value =
            user_id
            |> Revard.Storage.Users.get()
            |> List.first()

          :ets.insert(:cache, {user_id, value})
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
