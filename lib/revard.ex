defmodule Revard do
  use Application
  require Logger

  def start(_type, _args) do
    mongo_url = Application.get_env(:revard, :mongo_url)
    {port_to_listen, ""} = Integer.parse(Application.get_env(:revard, :port))

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Revard.Router,
        options: [
          dispatch: dispatch(),
          port: port_to_listen
        ]
      ),
      Registry.child_spec(keys: :unique, name: Bucket.Consumers),
      {Mongo,
       [
         name: :mongo,
         url: mongo_url,
         ssl: true,
         ssl_opts: [
           verify: :verify_peer,
           cacertfile: CAStore.file_path(),
           versions: [:"tlsv1.2"],
           customize_hostname_check: [
             {:match_fun, :public_key.pkix_verify_hostname_match_fun(:https)}
           ]
         ]
       ]},
      {Revard.Bot.Listener, Application.get_env(:revard, :revolt_websocket)},
      Revard.Task.Ping
    ]

    # Simple term storage for caching
    :ets.new(:cache, [:set, :public, :named_table])

    Logger.info("Starting server on port: #{port_to_listen}")

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
