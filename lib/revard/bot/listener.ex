defmodule Revard.Bot.Listener do
  @moduledoc """
  Revolt bot connection
  """

  use WebSockex

  require Logger

  alias Revard.Storage.Users
  alias Revard.Bot.Rest

  def start_link(host) do
    token = Application.get_env(:revard, :bot_token)

    (host <> "?version=1&format=json&token=" <> token)
    |> WebSockex.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_connect(_conn, state) do
    Logger.info("Established bot connection")
    {:ok, state}
  end

  def handle_frame({:text, message}, state) do
    message = Jason.decode!(message)

    case message["type"] do
      "Ready" ->
        case Rest.members() do
          {:ok, users} ->
            # These are some actions to sync database

            # Clear database from invalid users
            current_member_ids =
              users
              |> Enum.map(&Map.get(&1, "_id"))

            Users.get()
            |> Enum.map(&Map.get(&1, "_id"))
            |> Enum.filter(&(&1 not in current_member_ids))
            |> Users.remove()

            # Insert new members
            Users.insert(users)

          _ ->
            Logger.emergency("Failed to fetch server members")
        end

      "UserUpdate" ->
        data = %{id: message["id"], data: message["data"], clear: message["clear"]}

        Users.patch(data.id, data.data, data.clear)
        distribute_message(data)

      "ServerMemberLeave" ->
        Users.remove(message["user"])

      "ServerMemberJoin" ->
        message["user"]
        |> Rest.user()
        |> case do
          {:ok, data} ->
            Users.insert(data)

          _ ->
            Logger.error("Failed to fetch user information")
        end

      _ ->
        nil
    end

    {:ok, state}
  end

  ## Send message to subscribers
  defp distribute_message(packet) do
    info_packet = {:remote_message, Jason.encode!(%{type: "update", data: packet})}

    Revard.Bucket.Consumers
    |> Registry.select([{{:_, :"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.filter(fn {_, data} ->
      case data do
        [] -> true
        nil -> false
        other -> packet.id in other
      end
    end)
    |> Enum.map(fn {pid, _} -> pid end)
    |> Manifold.send(info_packet, pack_mode: :binary)
  end
end
