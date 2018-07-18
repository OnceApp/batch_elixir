# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config
config :batch_elixir, queue_implentation: BatchElixir.Server.Queue.Memory

config :batch_elixir,
  rest_api_key: "",
  devices: [],
  default_deeplink: "test://"

config :logger, backends: [:console], level: :debug
config :ex_unit, assert_receive_timeout: 2000
