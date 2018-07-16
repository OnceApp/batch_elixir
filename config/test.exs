use Mix.Config

config :batch_elixir,
  rest_api_key: "",
  default_deeplink: "test://"

config :logger, backends: [:console], level: :debug
config :ex_unit, assert_receive_timeout: 2000
