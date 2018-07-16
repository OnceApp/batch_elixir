defmodule BatchElixir.MixProject do
  # credo:disable-for-previous-line
  use Mix.Project

  def project do
    [
      app: :batch_elixir,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: test_coverage(System.get_env("CI"))
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
      {:cobertura_cover, "~> 0.9.0", only: :test},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:mock, "~> 0.3.0", only: :test},
      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev], runtime: false}
    ]
  end

  defp test_coverage(nil), do: [tool: CoberturaCover, html_output: "cover"]
  defp test_coverage(_), do: [tool: CoberturaCover]
end
