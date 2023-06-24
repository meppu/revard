defmodule Revard.Gateway.Listener do
  @moduledoc """
  WebSocket connection
  """

  require Logger

  def init(_opts) do
    {:ok, create_id()}
  end

  def handle_control({_message, [opcode: :ping]}, state) do
    Logger.debug("Handled ping (socket)")
    {:ok, state}
  end

  def handle_in({message, [opcode: :text]}, state) do
    case Jason.decode(message) do
      {:ok, decoded} when is_map(decoded) ->
        match_message(decoded, state)

      _ ->
        invalid_payload_error(state)
    end
  end

  def handle_in(_message, state) do
    {:ok, state}
  end

  def handle_info({:message, message}, state) do
    {:reply, :ok, {:text, Jason.encode!(%{type: "update", data: message})}, state}
  end

  def terminate(_reason, state) do
    {:ok, state}
  end

  ### Internal

  ## Actions for events
  defp match_message(%{"event" => "ping"}, state) do
    {:ok, state}
  end

  defp match_message(%{"event" => "subscribe", "ids" => ids}, state) when is_list(ids) do
    Logger.debug("Connection #{state} subscribed to following id(s): #{inspect(ids)} (socket)")

    # Check if all string
    if Enum.all?(ids, &is_binary/1) do
      Registry.update_value(Revard.Bucket.Consumers, state, fn _ -> ids end)

      initial_message =
        %{type: "init", data: Revard.Storage.Users.get(ids)}
        |> Jason.encode!()

      {:reply, :ok, {:text, initial_message}, state}
    else
      invalid_payload_error(state)
    end
  end

  defp match_message(%{"event" => "subscribe", "ids" => nil}, state) do
    Registry.update_value(Revard.Bucket.Consumers, state, fn _ -> nil end)

    {:ok, state}
  end

  defp match_message(_message, state) do
    invalid_payload_error(state)
  end

  ## Generate invalid payload response
  defp invalid_payload_error(state) do
    {:stop, :normal, {1002, "invalid_payload"}, state}
  end

  ## Generate an ID for session
  defp create_id() do
    id = Base.encode64(:crypto.strong_rand_bytes(12))

    case Registry.register(Revard.Bucket.Consumers, id, nil) do
      {:error, _} ->
        create_id()

      {:ok, _} ->
        Logger.debug("New connection: #{id} (socket)")
        id
    end
  end
end
