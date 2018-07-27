defmodule BehaviourTest do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      # worker(Clusterable, [], restart: :transient),
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :https,
        plug: BehaviourTest.Route,
        options: [
          port: 3000,
          otp_app: :behaviour_test,
          cipher_suite: :compatible,
          keyfile: System.cwd() <> "/../ssl/server.key",
          certfile: System.cwd() <> "/../ssl/server.crt"
        ]
      )
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one, name: BehaviourTest.Supervisor)
  end
end
