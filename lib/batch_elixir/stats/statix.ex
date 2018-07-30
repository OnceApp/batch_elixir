defmodule BatchElixir.Stats.Statix do
  use Statix
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    __MODULE__.connect()
    {:ok, nil}
  end

  def handle_cast({:increment, key, value}, _state) do
    __MODULE__.increment(key, value)
    {:noreply, nil}
  end

  def handle_cast({:timing, key, value}, _state) do
    __MODULE__.timing(key, value)
    {:noreply, nil}
  end

  def handle_call(:dump, _from, _state) do
    {:reply, nil, nil}
  end
end
