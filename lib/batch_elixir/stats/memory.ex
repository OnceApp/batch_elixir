defmodule BatchElixir.Stats.Memory do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{started: :os.system_time(:milli_seconds), count: %{}, timing: %{}}}
  end

  def handle_call({:increment, key, value}, _from, state) do
    current = state.count[key]
    {:reply, :ok, %{state | count: increment(current, state.count, key, value)}}
  end

  def handle_call({:measure, key, func}, _from, state) do
    {time, result} = :timer.tc(func)
    current = state.timing[key]
    {:reply, result, %{state | timing: increment(current, state.timing, key, time)}}
  end

  def handle_call(:dump, _from, state) do
    {:reply, state, state}
  end

  defp increment(nil, count, key, value), do: Map.merge(count, %{key => value})
  defp increment(current, count, key, value), do: Map.put(count, key, current + value)
end
