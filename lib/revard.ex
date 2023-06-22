defmodule Revard do
  use Application
  require Logger

  def start(_type, _args) do
    mongo_url = Application.get_env(:revard, :mongo_url)
    {port_to_listen, ""} = Integer.parse(Application.get_env(:revard, :port))

    children = [
      {Registry, keys: :unique, name: Revard.Bucket.Consumers},
      {Mongo, mongo_opts(mongo_url)},
      {Finch, name: Revard.Finch},
      {Revard.Bot.Listener, Application.get_env(:revard, :revolt_websocket)},
      Revard.Task.Ping,
      {Bandit, plug: Revard.Router, scheme: :http, port: port_to_listen}
    ]

    # Simple term storage for caching
    :ets.new(:cache, [:set, :public, :named_table])

    opts = [strategy: :one_for_one, name: Revard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp mongo_opts(url) do
    [
      name: Revard.Mongo,
      url: url,
      ssl: true,
      ssl_opts: [
        verify: :verify_peer,
        cacertfile: CAStore.file_path(),
        versions: [:"tlsv1.2"],
        customize_hostname_check: [
          {:match_fun, :public_key.pkix_verify_hostname_match_fun(:https)}
        ]
      ]
    ]
  end
end
