defmodule BatchElixir.Stats do
  @moduledoc """
  In memory implementation of Queue
  """
 
  def increment(key, value \\ 1) do
    GenServer.cast(BatchElixir.Stats, {:increment, key, value})
  end

  def timing(key, value) do
    GenServer.cast(BatchElixir.Stats, {:timing, key, value})
  end

  def measure(key, func) when is_function(func, 0) do
    {elapsed, result} = :timer.tc(func)
    timing(key, div(elapsed, 1000))
    result
  end

  def dump() do
    GenServer.call(BatchElixir.Stats, :dump)
  end
end
