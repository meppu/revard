defmodule Revard.MixProject do
  use Mix.Project

  def project do
    [
      app: :revard,
      version: "0.5.4",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Revard, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:websockex, "~> 0.4.3"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.14"},
      {:bandit, "~> 1.0.0-pre.10"},
      {:websock_adapter, "~> 0.5.3"},
      {:corsica, "~> 2.0"},
      {:finch, "~> 0.16.0"},
      {:castore, "~> 1.0"},
      {:mongodb_driver, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.1"}
    ]
  end
end
