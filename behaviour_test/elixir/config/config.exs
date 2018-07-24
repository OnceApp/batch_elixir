# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :batch_elixir,
  devices: [web: "B775B73B378B4A0183DF5519678C26F2"],
  default_deeplink: "test://",
  queue_implentation: BatchElixir.Server.Queue.Memory

config :logger, backends: [:console], level: :debug

config :hound,
  browser: "firefox",
  retry_time: 500
