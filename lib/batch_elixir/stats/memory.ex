defmodule BatchElixir.Stats.Memory do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: BatchElixir.Stats)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({_, key, value}, state) do
    current = state[key]
    {:noreply, increment(current, state, key, value)}
  end

  def handle_call(:dump, _from, state) do
    {:reply, state, state}
  end

  defp increment(nil, count, key, value), do: Map.merge(count, %{key => value})
  defp increment(current, count, key, value), do: Map.put(count, key, current + value)
end
