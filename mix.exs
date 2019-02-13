defmodule BatchElixir.MixProject do
  # credo:disable-for-previous-line
  use Mix.Project

  def project do
    [
      app: :batch_elixir,
      package: package(),
      version: "0.2.2",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      source_url: "https://github.com/OnceApp/batch_elixir",
      test_coverage: test_coverage(System.get_env("CI"))
    ]
  end

  defp description() do
    "A Batch elixir client"
  end

  defp package() do
    [
      name: "batch_elixir",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      links: %{"Github" => "https://github.com/OnceApp/batch_elixir"},
      licenses: ["MIT"]
    ]
  end

  def application do
    [
      env: [
        stats_driver: BatchElixir.Stats.Memory,
        producer_name: BatchElixir.Server.Producer,
        consumer_options: [],
        producer_options: [],
        number_of_consumers: 1,
        batch_url: "https://api.batch.com/1.1/",
        retry_interval_in_milliseconds: 1_000,
        max_attempts: 3
      ],
      applications: [:httpoison, :statix, :gen_stage],
      extra_applications: [:logger]
    ] ++ mod_application(Mix.env())
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:gen_stage, "~> 0.14"},
      {:poison, "~> 3.1"},
      {:statix, "~> 1.1"},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19.3", only: :dev},
      {:cobertura_cover, "~> 0.9.0", only: :test},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:mock, "~> 0.3.0", only: :test},
      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev, :test], runtime: false},
      {:progress_bar, "~> 2.0", only: [:dev, :test]},
      {:timex, "~> 3.5", only: [:dev, :test]},
      {:table_rex, "~> 2.0", only: [:dev, :test]},
      {:logger_file_backend, "~> 0.0.10", only: [:dev, :test]}
    ]
  end

  defp mod_application(:test), do: []
  defp mod_application(_env), do: [mod: {BatchElixir.Application, []}]

  defp test_coverage(nil), do: [tool: CoberturaCover, html_output: "cover"]
  defp test_coverage(_), do: [tool: CoberturaCover]
end
