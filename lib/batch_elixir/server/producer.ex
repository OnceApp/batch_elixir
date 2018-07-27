defmodule BatchElixir.Server.Producer do
  @moduledoc false
  use GenStage
  alias BatchElixir.Environment
  alias BatchElixir.RestClient.Transactional
  require Logger

  def start_link do
    Logger.info(fn -> "Starting producer" end)
    GenStage.start_link(__MODULE__, :ok, name: Environment.get(:producer_name))
  end

  def init(:ok) do
    {:producer, 0}
  end

  def handle_demand(incoming_demand, _state) do
    dispatch_events(incoming_demand)
  end

  def handle_cast({_, :transactional, %Transactional{}} = event, _demands) do
    Environment.get(:queue_implementation).push(event)
    dispatch_events(1)
  end

  @doc """
  Send a notification through the transactional API of *Batch*
  """
  def send_notification(api_key, %Transactional{} = transactional) do
    GenStage.cast(Environment.get(:producer_name), {api_key, :transactional, transactional})
  end

  defp dispatch_events(0) do
    {:noreply, [], 0}
  end

  defp dispatch_events(demands) do
    events = Environment.get(:queue_implementation).pop(demands)
    {:noreply, events, demands}
  end
end
