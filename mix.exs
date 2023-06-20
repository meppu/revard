defmodule Revard.MixProject do
  use Mix.Project

  def project do
    [
      app: :revard,
      version: "0.2.1",
      elixir: "~> 1.12",
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
      {:bandit, "~> 0.7.7"},
      {:websock_adapter, "~> 0.5.3"},
      {:httpoison, "~> 2.1"},
      {:mongodb_driver, "~> 1.0"},
      {:castore, "~> 1.0"}
    ]
  end
end
