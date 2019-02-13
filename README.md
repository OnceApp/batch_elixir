# BatchElixir

Send transactional notifications to Batch

## Installation

If [available in Hex](https://hexdocs.pm/batch_elixir), the package can be installed
by adding `batch_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:batch_elixir, "~> 0.2.0"}
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
  producer_name: BatchElixir.Server.Producer, # name of the producer. By default the producer is BatchElixir.Server.Producer
  consumer_options: [], # extra options for GenStage as consumer. Typically [min_demand:10, max_demand: 100]
  producer_options: [], # extra options for GenStage as producer. Typically [buffer_size: 10_000]
  batch_url: "https://api.batch.com/1.1/", # Base url of batch api
  retry_interval_in_milliseconds: 1_000, # Interval between each failed requests
  max_attempts: 3, # Maximum attempts of failed requests
  number_of_consumers: 1, # Number of consumers to pop. By default is 1
  stats_driver: BatchElixir.Stats.Memory # BatchElixir.Stats.Memory For In memory stats or BatchElixir.Stats.Statix to send to datadog via Statix
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/batch_elixir](https://hexdocs.pm/batch_elixir).

## Behaviour testing

For behaviour test please refers to [README.md](./behaviour_test/README.md)

## Stress test

If you want a stub for batch check [README.md](./stub_batch/README.md).

To run the test

```elixir
mix benchmark --config stress_test/config.json [--observer] --max number_of_consumers  number_of_notification number_of_iterations
```

* `--config`: configuration file
* `--observer`: Launche the observer window
* `number_of_consumers`: Numer of consumers.
* `number_of_notification`: Numer of notifications to send.
* `number_of_iterations`: Numer of iterations to run.

You also have bash script that will run 1, 10, 100, 1000, 10000, 1000000 notifications with 10, 100, 1000 consumers each.

```bash
./stress_test.sh [--observer]
```

Warns and errors will be outputed to the file: `stress_test.log`