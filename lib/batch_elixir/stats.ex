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
    GenServer.call(get_stats_driver(), {:increment, key, value})
  end

  def measure(key, func) do
    GenServer.call(get_stats_driver(), {:measure, key, func})
  end

  def dump() do
    GenServer.call(get_stats_driver(), :dump)
  end
end
