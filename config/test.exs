use Mix.Config

config :batch_elixir,
  api_key: "",
  rest_api_key: "",
  producer: BatchElixir.Server.Producer,
  default_deeplink: "test://"

config :logger, backends: [:console], level: :debug
config :ex_unit, assert_receive_timeout: 2000

config :excov, :reporters, [
  ExCov.Reporter.Console
]
config :excov, ExCov.Reporter.Console,
  show_summary: true,
  show_detail: false
