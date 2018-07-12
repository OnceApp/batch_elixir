defmodule BatchElixir.Server.Producer do
  use GenStage
  alias BatchElixir.RestClient.Transactional

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer, :ok, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_demand(_demand, state), do: {:noreply, [], state}

  def handle_call(event = {:transactional, %Transactional{}}, _from, state) do
    # Dispatch immediately
    {:reply, :ok, [event], state}
  end

  def send_event(event = {:transactional, %Transactional{}}, timeout \\ 5000) do
    GenStage.call(__MODULE__, event, timeout)
  end
end
