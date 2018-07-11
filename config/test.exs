use Mix.Config

config :batch_elixir, api_key: "", rest_api_key: "", producer: BatchElixir.Server.Producer
config :logger, backends: [:console], level: :debug
config :ex_unit, assert_receive_timeout: 2000
