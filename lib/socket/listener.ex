defmodule Revard.Socket.Listener do
  @behaviour :cowboy_websocket

  defstruct [:ids, :last_ping]

  def init(request, _state), do: {:cowboy_websocket, request, nil}

  def websocket_init(_state), do: {:ok, create_id()}

  def websocket_handle({:text, message}, state) do
    case Jason.decode(message) do
      {:ok, decoded} when is_map(decoded) ->
        update_ping(state)
        match_message(decoded, state)

      _ ->
        {:reply, {:close, 1002, "invalid_payload"}, state}
    end
  end

  def websocket_info({:message, message}, state), do: {:reply, {:text, message}, state}
  def websocket_info(:close, state), do: {:close, state}

  # ping
  defp match_message(%{"event" => "ping"}, state), do: {:ok, state}

  # subscribe
  defp match_message(%{"event" => "subscribe", "ids" => ids}, state) when is_list(ids) do
    if Enum.all?(ids, &is_binary/1) do
      Registry.update_value(Bucket.Consumers, state, &%{&1 | ids: ids})
      {:ok, state}
    else
      {:reply, {:close, 1002, "invalid_payload"}, state}
    end
  end

  defp update_ping(id) do
    Registry.update_value(Bucket.Consumers, id, &%{&1 | last_ping: DateTime.utc_now()})
  end

  defp create_id do
    id = Base.encode16(:crypto.strong_rand_bytes(20))
    data = %__MODULE__{ids: nil, last_ping: DateTime.utc_now()}

    case Registry.register(Bucket.Consumers, id, data) do
      {:error, _} ->
        create_id()

      {:ok, _} ->
        id
    end
  end
end
