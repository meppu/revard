defmodule Revard.Socket.Listener do
  @behaviour :cowboy_websocket

  require Logger

  defstruct [:ids, :last_ping]

  def init(request, _state),
    do:
      {:cowboy_websocket, request, nil,
       %{
         max_frame_size: 8192
       }}

  def websocket_init(_state), do: {:ok, create_id()}

  def websocket_handle({:ping, _message}, state) do
    Logger.debug("Handled ping (socket)")

    update_ping(state)
    {:reply, {:pong, ":)"}, state}
  end

  def websocket_handle({:text, message}, state) do
    case Jason.decode(message) do
      {:ok, decoded} when is_map(decoded) ->
        update_ping(state)
        match_message(decoded, state)

      _ ->
        {:reply, {:close, 1002, "invalid_payload"}, state}
    end
  end

  def websocket_handle(_message, state), do: {:ok, state}

  def websocket_info({:message, message}, state),
    do: {:reply, {:text, Jason.encode!(%{type: "update", data: message})}, state}

  def websocket_info(:close, state), do: {:reply, {:close, 1012, "inactive_connection"}, state}

  defp match_message(%{"event" => "ping"}, state), do: {:ok, state}

  defp match_message(%{"event" => "subscribe", "ids" => ids}, state) when is_list(ids) do
    Logger.debug("Connection #{state} subscribed to following id(s): #{inspect(ids)} (socket)")

    if Enum.all?(ids, &is_binary/1) do
      Registry.update_value(Bucket.Consumers, state, &%{&1 | ids: ids})

      initial_message =
        %{type: "init", data: Revard.Storage.Users.get(ids)}
        |> Jason.encode!()

      {:reply, {:text, initial_message}, state}
    else
      {:reply, {:close, 1002, "invalid_payload"}, state}
    end
  end

  defp match_message(%{"event" => "subscribe", "ids" => nil}, state) do
    Registry.update_value(Bucket.Consumers, state, &%{&1 | ids: nil})
    {:ok, state}
  end

  defp match_message(_message, state), do: {:reply, {:close, 1002, "invalid_payload"}, state}

  ### Internal

  defp update_ping(id) do
    Logger.debug("Connection pinged: #{id} (socket)")
    Registry.update_value(Bucket.Consumers, id, &%{&1 | last_ping: DateTime.utc_now()})
  end

  defp create_id do
    id = Base.encode16(:crypto.strong_rand_bytes(20))
    data = %__MODULE__{ids: nil, last_ping: DateTime.utc_now()}

    case Registry.register(Bucket.Consumers, id, data) do
      {:error, _} ->
        create_id()

      {:ok, _} ->
        Logger.debug("New connection: #{id} (socket)")
        id
    end
  end
end
