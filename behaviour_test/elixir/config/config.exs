# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :batch_elixir,
  devices: [],
  default_deeplink: "test://",
  queue_implentation: BatchElixir.Server.Queue.Memory

config :behaviour_test, api_key: ""
config :logger, backends: [:console], level: :debug

config :clusterable,
  cookie: :my_cookie,
  app_name: "my_app"

config :libcluster,
  topologies: [
    clusterable: [strategy: Cluster.Strategy.Gossip]
  ]
