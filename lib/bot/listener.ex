defmodule Revard.Bot.Listener do
  use WebSockex

  alias Revard.Storage

  def start_link(host) do
    token = Application.get_env(:revard, :bot_token)

    (host <> "?version=1&format=json&token=" <> token)
    |> WebSockex.start_link(__MODULE__, nil)
  end

  def handle_frame({:text, message}, state) do
    message = Jason.decode!(message)

    case message["type"] do
      "Ready" ->
        case Revard.Bot.Rest.members() do
          {:ok, users} -> Storage.Users.insert(users)
          # TODO: Log error
          _ -> :noop
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
          {:ok, data} -> Storage.Users.insert(data)
          _ -> :noop
        end

      _ ->
        :noop
    end

    {:ok, state}
  end

  def handle_cast(_frame, state), do: {:ok, state}

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
