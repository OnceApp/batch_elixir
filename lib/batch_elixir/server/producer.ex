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
    {:producer, %{queue: :queue.new(), demand: 0}, Environment.get(:producer_options)}
  end

  def handle_info(:get_messages, state) do
    number = min(state.demand, 100)

    {queue, remaining_queue} =
      state.queue
      |> is_queue_size_smaller_than_demand?(number)
      |> keep_intact_or_split_queue(state.queue, number)

    events = queue |> :queue.to_list()

    retrieved_demands = length(events)
    new_demand = state.demand - retrieved_demands
    get_more_message_if_required(new_demand, retrieved_demands)

    {:noreply, events, %{queue: remaining_queue, demand: new_demand}}
  end

  defp keep_intact_or_split_queue(true, queue, _number) do
    {queue, :queue.new()}
  end

  defp keep_intact_or_split_queue(false, queue, number) do
    :queue.split(number, queue)
  end

  defp is_queue_size_smaller_than_demand?(queue, demand), do: :queue.len(queue) < demand
  defp get_more_message_if_required(0, _retrieved_demands), do: :ok

  defp get_more_message_if_required(_new_demands, 0),
    do: Process.send_after(self(), :get_messages, 200)

  defp get_more_message_if_required(_new_demands, _retrieved_demands),
    do: Process.send(self(), :get_messages, [])

  def handle_demand(incoming_demand, %{demand: 0} = state) do
    new_demand = state.demand + incoming_demand
    Process.send(self(), :get_messages, [])
    {:noreply, [], %{state | demand: new_demand}}
  end

  def handle_demand(incoming_demand, state) do
    new_demand = state.demand + incoming_demand
    {:noreply, [], %{state | demand: new_demand}}
  end

  def handle_cast({_, :transactional, %Transactional{}} = event, state) do
    queue = add_event({event, 0}, state.queue)
    {:noreply, [], %{state | queue: queue}}
  end

  def handle_cast(events, state) when is_list(events) do
    queue =
      events
      |> Enum.reduce(state.queue, &add_event/2)

    {:noreply, [], %{state | queue: queue}}
  end

  defp add_event(event, queue), do: :queue.in(event, queue)

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
end
