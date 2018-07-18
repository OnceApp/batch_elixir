defmodule BehaviourTest do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
     # worker(Clusterable, [], restart: :transient),
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: BehaviourTest.Route,
        options: [port: 8080]
      )
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one, name: BehaviourTest.Supervisor)
  end
end
