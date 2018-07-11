defmodule BatchElixir.MixProject do
  use Mix.Project

  @ignore_modules File.read!("./.coverignore")
                  |> String.split("\n")
                  |> Enum.map(&String.to_atom(&1))

  def project do
    [
      app: :batch_elixir,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls, ignore_modules: @ignore_modules]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpoison],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:gen_stage, "~> 0.14"},
      {:poison, "~> 3.1"},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.18.3", only: :dev},
      {:excoveralls, "~> 0.9.1", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
