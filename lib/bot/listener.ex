defmodule Revard.Bot.Listener do
  use WebSockex

  def start_link(host) do
    token = Application.get_env(:revard, :bot_token)

    (host <> "?version=1&format=json&token=" <> token)
    |> WebSockex.start_link(__MODULE__, nil)
  end

  def handle_frame({:text, message}, state) do
    message = Jason.decode!(message)

    if message["type"] == "UserUpdate" do
      %{id: message["id"], data: message["data"]}
      |> distribute_message()
    end

    {:ok, state}
  end

  def handle_cast(_frame, state), do: {:ok, state}

  defp distribute_message(packet) do
    encoded = Jason.encode!(packet)

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
      send(pid, {:message, encoded})
    end)
  end
end
