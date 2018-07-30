defmodule BatchElixir.Stats do
  @moduledoc """
  In memory implementation of Queue
  """
  alias BatchElixir.Environment

  def start_link do
    stats_driver = get_stats_driver()
    stats_driver.start_link()
  end

  defp get_stats_driver do
    Environment.get(:stats_driver)
  end

  def increment(key, value \\ 1) do
    GenServer.cast(get_stats_driver(), {:increment, key, value})
  end

  def timing(key, value) do
    GenServer.cast(get_stats_driver(), {:timing, key, value})
  end

  def measure(key, func) when is_function(func, 0) do
    {elapsed, result} = :timer.tc(func)
    timing(key, div(elapsed, 1000))
    result
  end

  def dump() do
    GenServer.call(get_stats_driver(), :dump)
  end
end
