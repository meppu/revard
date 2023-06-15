defmodule Revard do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Registry.child_spec(
        keys: :unique,
        name: Bucket.Consumers
      ),
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Revard.Router,
        options: [
          dispatch: dispatch(),
          port: 8000
        ]
      ),
      {Revard.Bot.Listener, Application.get_env(:revard, :revolt_websocket)}
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
