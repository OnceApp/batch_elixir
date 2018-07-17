defmodule BatchElixir.Server.Producer do
  @moduledoc false
  use GenStage
  alias BatchElixir.RestClient.Transactional
  require Logger
  @global_producer_service {:global, BatchProducer}
  @queue_implementation Application.fetch_env!(:batch_elixir, :queue_implentation)
  def start_link do
    Logger.info(fn -> "Starting producer" end)
    case GenStage.start_link(__MODULE__, :ok, name: @global_producer_service) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Process.link(pid)
        {:ok, pid}
    end
  end

  def init(:ok) do
    {:producer, 0}
  end

  def handle_demand(incoming_demand, pending_demand) do
    dispatch_events(incoming_demand + pending_demand)
  end

  def handle_cast({_, :transactional, %Transactional{}} = event, pending_demand) do
    @queue_implementation.push(event)
    dispatch_events(pending_demand)
  end

  @doc """
  Send a notification through the transactional API of *Batch*
  """
  def send_notification(api_key, %Transactional{} = transactional) do
    GenStage.cast(@global_producer_service, {api_key, :transactional, transactional})
  end

  defp dispatch_events(0) do
    {:noreply, [], 0}
  end

  defp dispatch_events(demand) do
    events = @queue_implementation.pop(demand)
    {:noreply, events, demand}
  end
end
