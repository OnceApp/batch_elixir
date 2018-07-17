use Mix.Config

config :batch_elixir,
  default_deeplink: "test://"

config :logger, backends: [:console], level: :debug
