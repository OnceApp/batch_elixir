defmodule StubBatch do
  alias StubBatch.Toxiproxy
  use Application
  require Logger

  def start(_type, arguments) do
    import Supervisor.Spec, warn: false
    arguments = Toxiproxy.setup_toxiproxy_and_correct_port(arguments)
    port = arguments.port

    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: StubBatch.Route,
        options: [
          port: port
        ]
      )
    ]

    Logger.info("Listening on port #{port}")
    Supervisor.start_link(children, strategy: :one_for_one, name: StubBatch.Supervisor)
  end
end
