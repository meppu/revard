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
      packet = %{id: message["id"], data: message["data"]}
      IO.inspect(packet)

      # TODO: Send to consumers
    end

    {:ok, state}
  end

  def handle_cast(_frame, state), do: {:ok, state}
end
