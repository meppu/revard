defmodule Revard do
  @moduledoc """
  Start point for Revard
  """

  use Application

  require Logger

  def start(_type, _args) do
    mongo_url = Application.get_env(:revard, :mongo_url)
    {port_to_listen, ""} = Integer.parse(Application.get_env(:revard, :port))

    children = [
      # Cache storage
      Revard.Storage.Cache,
      # MongoDB connection
      {Mongo, mongo_opts(mongo_url)},
      # Finch
      {Finch, name: Revard.Finch},
      # PubSub
      {Phoenix.PubSub, keys: :unique, name: Revard.PubSub},
      # Revolt bot
      {Revard.Bot.Listener, Application.get_env(:revard, :revolt_websocket)},
      # Revolt pinger
      Revard.Task.Ping,
      # Web server
      {Bandit, plug: Revard.Router, scheme: :http, port: port_to_listen}
    ]

    opts = [strategy: :one_for_one, name: Revard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  ## Create MongoDB settings
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
