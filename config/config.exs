# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config
config :batch_elixir, queue_implentation: BatchElixir.Server.Queue.Memory

import_config "#{Mix.env()}.exs"
