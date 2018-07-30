defmodule StubBatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :stub_batch,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  defp escript do
    [main_module: StubBatch.CLI]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:cowboy, :plug, :httpoison],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.0"},
      {:plug, "~> 1.0"},
      {:uuid, "~> 1.1"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"}
    ]
  end
end
