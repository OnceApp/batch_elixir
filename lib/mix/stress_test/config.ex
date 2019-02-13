defmodule StressTest.Config do
  alias Poison.Decoder
  alias Poison.Parser

  @default [
    stats_driver: BatchElixir.Stats.Memory,
    producer_name: {:global, BatchProducer},
    consumer_options: [],
    producer_options: [buffer_size: :infinity],
    queue_name: {:global, BatchQueue},
    number_of_consumers: 1,
    batch_url: "http://localhost:8080/",
    rest_api_key: "test",
    devices: [web: "test"],
    retry_interval_in_milliseconds: 1_000,
    max_attempts: 3
  ]
  def setup(options, default \\ true)

  def setup(options, default) when is_binary(options) do
    set_default(default)
    load_configuration_from_json(File.read(options))
  end

  def setup(options, default) do
    set_default(default)
    setup_config(options)
  end

  defp set_default(true), do: setup_config(@default)

  defp set_default(false) do
  end

  defp load_configuration_from_json({:ok, config}) do
    config
    |> Parser.parse!(keys: :atoms)
    |> Decoder.decode([])
    |> setup_config
  end

  defp load_configuration_from_json(_) do
  end

  defp setup_config(options) do
    Logger.remove_backend(:console)
    Logger.add_backend({LoggerFileBackend, :stress_test})

    Logger.configure_backend(
      {LoggerFileBackend, :stress_test},
      path: File.cwd() <> "/stress_test.log",
      level: :warn
    )

    # Logger.configure_backend(:console, level: :warn)
    Enum.each(options, &_setup_config/1)
  end

  defp _setup_config({key, value}) when is_binary(key) do
    Application.put_env(:batch_elixir, String.to_atom(key), value)
  end

  defp _setup_config({key, value}) do
    Application.put_env(:batch_elixir, key, value)
  end
end
