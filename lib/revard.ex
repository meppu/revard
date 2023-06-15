defmodule Revard do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Registry.child_spec(
        keys: :unique,
        name: Bucket.Consumers
      ),
      {Revard.Bot.Listener, "wss://ws.revolt.chat"}
    ]

    opts = [strategy: :one_for_one, name: Revard.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
