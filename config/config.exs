import Config

config :logger,
  level: if(Mix.env() == :prod, do: :info, else: :debug)
