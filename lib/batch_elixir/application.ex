defmodule BatchElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @queue_implementation :"Elixir.Application".fetch_env!(:batch_elixir, :queue_implentation)
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(@queue_implementation, [], restart: :permanent),
      worker(BatchElixir.Server.Producer, [], restart: :permanent),
      worker(BatchElixir.Server.Consumer, [], restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: BatchElixir.Supervisor]
    Logger.info(fn -> "Starting Batch API" end)
    Supervisor.start_link(children, opts)
  end
end
