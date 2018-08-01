defmodule BatchElixir.Application do
  @moduledoc false
  @required_configuration_keys [:rest_api_key]
  alias BatchElixir.Environment
  alias BatchElixir.Server.Consumer
  alias BatchElixir.Server.Producer

  use Application
  require Logger

  def start(_type, _args) do
    ensure_required_configuration() |> _start
  end

  defp _start([]) do
    number_of_consumers = Environment.get(:number_of_consumers)

    consumers =
      for i <- 1..number_of_consumers do
        %{
          id: i,
          start: {Consumer, :start_link, []},
          restart: :permanent
        }
      end

    children =
      [
        %{
          id: BatchElixir.Server.Producer,
          start: {Producer, :start_link, []},
          restart: :permanent
        },
        %{
          id: BatchElixir.Stats,
          start: {BatchElixir.Stats, :start_link, []},
          restart: :permanent
        }
      ] ++ consumers

    opts = [strategy: :one_for_one, name: BatchElixir.Supervisor]
    Logger.info(fn -> "Starting Batch API" end)
    Supervisor.start_link(children, opts)
  end

  defp _start(errored) do
    {:error, {:shutdown, errored}}
  end

  defp ensure_required_configuration do
    @required_configuration_keys
    |> Enum.map(&Environment.ensure/1)
    |> Enum.filter(&filter_undefined_key/1)
  end

  defp filter_undefined_key(:ok), do: false
  defp filter_undefined_key({:error, _}), do: true
end
