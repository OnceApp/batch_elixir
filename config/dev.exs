use Mix.Config

config :batch_elixir,
  rest_api_key: "",
  default_deeplink: "test://"

config :logger, backends: [:console], level: :debug
