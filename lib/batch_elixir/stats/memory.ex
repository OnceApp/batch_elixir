defmodule BatchElixir.Stats.Memory do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{started: System.system_time(:milliseconds), count: %{}, timing: %{}}}
  end

  def handle_cast({:increment, key, value}, state) do
    current = state.count[key]
    {:noreply, %{state | count: increment(current, state.count, key, value)}}
  end

  def handle_cast({:timing, key, value}, state) do
    current = state.timing[key]
    {:noreply, %{state | timing: increment(current, state.timing, key, value)}}
  end

  def handle_call(:dump, _from, state) do
    {:reply, state, state}
  end

  defp increment(nil, count, key, value), do: Map.merge(count, %{key => value})
  defp increment(current, count, key, value), do: Map.put(count, key, current + value)
end
