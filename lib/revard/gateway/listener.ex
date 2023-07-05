defmodule Revard.Gateway.Listener do
  @moduledoc """
  WebSocket connection

  State holds current subscribers
  """

  require Logger

  @pubsub Revard.PubSub

  def init(_opts) do
    {:ok, []}
  end

  def handle_control({_message, [opcode: :ping]}, state) do
    Logger.debug("Handle ping frame (socket)")
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

  def handle_info({:remote_message, message}, state) do
    {:reply, :ok, {:text, message}, state}
  end

  def terminate(_reason, state) do
    {:ok, state}
  end

  ### Internal

  ## Actions for events
  defp match_message(%{"event" => "ping"}, state) do
    Logger.debug("Handle ping event (socket)")
    {:ok, state}
  end

  defp match_message(%{"event" => "subscribe", "ids" => nil}, state) do
    # Unsubscribe all
    Enum.each(state, &Phoenix.PubSub.unsubscribe(@pubsub, &1))

    {:ok, []}
  end

  defp match_message(%{"event" => "subscribe", "ids" => []} = message, state) do
    message
    |> Map.put("ids", nil)
    |> match_message(state)
  end

  defp match_message(%{"event" => "subscribe", "ids" => ids}, state) when is_list(ids) do
    # Check format
    if Enum.all?(ids, &check_id/1) do
      # Unsubscribe all
      Enum.each(state, &Phoenix.PubSub.unsubscribe(@pubsub, &1))

      # Debug message
      Logger.debug(
        "Connection #{inspect(self())} subscribing to following id(s): #{inspect(ids)} (socket)"
      )

      # Subscribe given ones
      Enum.each(ids, &Phoenix.PubSub.subscribe(@pubsub, &1))

      # Reply with initial message
      initial_message =
        %{type: "init", data: Revard.Storage.Users.get(ids)}
        |> Jason.encode!()

      {:reply, :ok, {:text, initial_message}, ids}
    else
      invalid_payload_error(state)
    end
  end

  defp match_message(%{"event" => "list"}, state) do
    message = {:text, Jason.encode!(state)}
    {:reply, :ok, message, state}
  end

  defp match_message(_message, state) do
    invalid_payload_error(state)
  end

  ## Generate invalid payload response
  defp invalid_payload_error(state) do
    {:stop, :normal, {1002, "invalid_payload"}, state}
  end

  ## Check if id has correct format
  defp check_id(id) when is_binary(id) do
    Regex.match?(~r/^[0-7][0-9A-HJKMNP-TV-Z]{25}$/, id)
  end

  defp check_id(_other) do
    false
  end
end
