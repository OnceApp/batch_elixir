defmodule BatchElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias BatchElixir.Environment

  use Application
  require Logger

  def start(_type, _args) do
    number_of_consumers = Environment.get(:number_of_consumers)
    queue_implementation = Environment.get(:queue_implementation)

    consumers =
      for i <- 1..number_of_consumers do
        %{
          id: i,
          start: {BatchElixir.Server.Consumer, :start_link, []},
          restart: :permanent
        }
      end

    children =
      [
        %{
          id: queue_implementation,
          start: {queue_implementation, :start_link, []},
          restart: :permanent
        },
        %{
          id: BatchElixir.Server.Producer,
          start: {BatchElixir.Server.Producer, :start_link, []},
          restart: :permanent
        }
      ] ++ consumers

    opts = [strategy: :one_for_one, name: BatchElixir.Supervisor]
    Logger.info(fn -> "Starting Batch API" end)
    Supervisor.start_link(children, opts)
  end
end
