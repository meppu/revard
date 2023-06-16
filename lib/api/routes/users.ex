defmodule Revard.API.Routes.Users do
  alias Revard.API.Utils
  alias Revard.Cache

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/:id" do
    %Plug.Conn{params: %{"id" => user_id}} = conn

    response =
      user_id
      |> Cache.Users.get()
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
