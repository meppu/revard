defmodule Revard do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Registry.child_spec(
        keys: :unique,
        name: Bucket.Consumers
      ),
      {Revard.Bot.Listener, Application.get_env(:revard, :revolt_websocket)}
    ]

    opts = [strategy: :one_for_one, name: Revard.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
