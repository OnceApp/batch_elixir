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
    {:producer, 0, Environment.get(:producer_options)}
  end

  def handle_demand(_incoming_demand, _state) do
    dispatch_events(0)
  end

  def handle_cast({_, :transactional, %Transactional{}} = event, _demands) do
    dispatch_events([{event, 0}])
  end

  def handle_cast(events, _demands) when is_list(events) do
    dispatch_events(events)
  end

  @doc """
  Send a notification through the transactional API of *Batch*
  """
  def send_notification(api_key, %Transactional{} = transactional) do
    GenStage.cast(Environment.get(:producer_name), {api_key, :transactional, transactional})
  end

  @doc """
  Send a notification through the transactional API of *Batch*
  """
  def send_notifications(events) do
    GenStage.cast(Environment.get(:producer_name), events)
  end

  defp dispatch_events(0) do
    {:noreply, [], 0}
  end

  defp dispatch_events(events) do
    {:noreply, events, length(events)}
  end
end
