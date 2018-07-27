defmodule BatchElixir.Stats.Statix do
  use Statix
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    BatchElixir.Stats.Statix.connect()
    {:ok, nil}
  end

  def handle_call({:increment, key, value}, _from, _state) do
    BatchElixir.Stats.Statix.increment(key, value)
    {:reply, :ok, nil}
  end

  def handle_call({:measure, key, func}, _from, _state) do
    result = BatchElixir.Stats.Statix.measure(key, [], func)
    {:reply, result, nil}
  end

  def handle_call(:dump, _from, _state) do
    {:reply, nil, nil}
  end
end
