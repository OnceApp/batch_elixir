# BatchElixir

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `batch_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:batch_elixir, "~> 0.1.0"}
  ]
end
```

```elixir
def application do
  [
    applications: [:batch_elixir]
  ]
end
```

## Configuration

```elixir
config :batch_elixir,
  rest_api_key: "rest api key", # Required, if not provided the application fail to start
  devices: "your rest api key of batch", # required
  default_deeplink: "myapp://" # required,
  producer_name: {:global, BatchProducer}, # name of the producer. By default the producer is global
  consumer_options: [], # extra options for GenStage as consumer. Typically [min_demand:10, max_demand: 100]
  queue_name: {:global, BatchQueue}, # name of the queue service. By default the producer is global
  queue_implementation: BatchElixir.Server.Queue.Memory, # Implentation used for the queue. By default the queue is in memory
  number_of_consumers: 1 # Number of consumers to pop. By default is 1
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/batch_elixir](https://hexdocs.pm/batch_elixir).

## Behaviour testing

For behaviour test please refers to [README.md](./behaviour_test/README.md)