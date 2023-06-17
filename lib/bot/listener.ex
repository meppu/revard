defmodule Revard.Bot.Listener do
  use WebSockex

  alias Revard.Storage

  require Logger

  def start_link(host) do
    Logger.info("Starting bot connection")

    token = Application.get_env(:revard, :bot_token)

    (host <> "?version=1&format=json&token=" <> token)
    |> WebSockex.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def handle_frame({:text, message}, state) do
    message = Jason.decode!(message)

    case message["type"] do
      "Ready" ->
        case Revard.Bot.Rest.members() do
          {:ok, users} ->
            # These are some actions to sync database

            # Clear database from invalid users
            current_member_ids =
              users
              |> Enum.map(&Map.get(&1, "_id"))

            Storage.Users.get()
            |> Enum.map(&Map.get(&1, "_id"))
            |> Enum.filter(&(&1 not in current_member_ids))
            |> Storage.Users.remove()

            # Insert new members
            Storage.Users.insert(users)

          _ ->
            Logger.emergency("Failed to fetch server members")
        end

      "UserUpdate" ->
        data = %{id: message["id"], data: message["data"], clear: message["clear"]}

        Storage.Users.patch(data.id, data.data, data.clear)
        distribute_message(data)

      "ServerMemberLeave" ->
        Storage.Users.remove(message["user"])

      "ServerMemberJoin" ->
        message["user"]
        |> Revard.Bot.Rest.user()
        |> case do
          {:ok, data} ->
            Storage.Users.insert(data)

          _ ->
            Logger.error("Failed to fetch user information")
        end

      _ ->
        :noop
    end

    {:ok, state}
  end

  defp distribute_message(packet) do
    Bucket.Consumers
    |> Registry.select([{{:_, :"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.filter(fn {_, data} ->
      case data.ids do
        [] -> true
        nil -> false
        other -> packet.id in other
      end
    end)
    |> Enum.map(fn {pid, _} ->
      send(pid, {:message, packet})
    end)
  end
end
