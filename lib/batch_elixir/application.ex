defmodule BatchElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @queue_implementation :"Elixir.Application".fetch_env!(:batch_elixir, :queue_implentation)
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(@queue_implementation, []),
      worker(BatchElixir.Server.Producer, []),
      worker(BatchElixir.Server.Consumer, [])
    ]

    opts = [strategy: :one_for_one, name: BatchElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
