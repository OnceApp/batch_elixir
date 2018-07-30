# StubBatch

## Installation

```bash
mix escript.build
```

```bash
./stub_batch --toxiproxy --latency 1000 --jitter 500 8080
```

* `--toxiproxy`: configure toxiproxy. Toxiproxy must be running. If not toxiproxy will not be configured.
* `--latency ms`: Latency in milliseconds. (Must have `toxiproxy` flag enabled)
* `--jitter ms`: Jitter in milliseconds (latency +/- jitter). (Must have `toxiproxy` flag enabled) 
* `port`: Port of the stub (default to 8080)