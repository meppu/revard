defmodule Revard.API.Routes.Users do
  alias Revard.API.Utils
  alias Revard.Storage

  use Plug.Router

  require Logger

  plug(:match)
  plug(:dispatch)

  get "/:id" do
    %Plug.Conn{params: %{"id" => user_id}} = conn

    Logger.debug("Getting #{user_id}'s information (http)")

    response =
      user_id
      |> Storage.Users.get()
      |> List.first()

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
