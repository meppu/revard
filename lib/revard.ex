defmodule Revard do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Revard.Router,
        options: [
          dispatch: dispatch(),
          port: 8000
        ]
      ),
      Registry.child_spec(keys: :unique, name: Bucket.Consumers),
      {Revard.Bot.Listener, Application.get_env(:revard, :revolt_websocket)},
      Revard.Task.Ping,
      Revard.Task.Snapshot,
      Revard.Cache.Users
    ]

    opts = [strategy: :one_for_one, name: Revard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/gateway", Revard.Socket.Listener, []},
         {:_, Plug.Cowboy.Handler, {Revard.Router, []}}
       ]}
    ]
  end
end
