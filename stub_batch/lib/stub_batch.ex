defmodule StubBatch do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    port = Application.get_env(:stub_batch, :port, 8080)

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
