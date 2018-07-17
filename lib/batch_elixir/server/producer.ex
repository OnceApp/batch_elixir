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

  def handle_call({_, :transactional, %Transactional{}} = event, _from, state) do
    # Dispatch immediately
    {:reply, :ok, [event], state}
  end

  @doc """
  Send a notification through the transactional API of *Batch*
  """
  def send_notification(api_key, %Transactional{} = transactional, timeout \\ 5000) do
    dispatch_event({api_key, :transactional, transactional}, timeout)
  end

  defp dispatch_event(event, timeout) do
    GenStage.call(__MODULE__, event, timeout)
  end
end
