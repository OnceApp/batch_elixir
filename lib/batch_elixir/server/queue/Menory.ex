defmodule BatchElixir.Server.Queue.Memory do
  @moduledoc """
  In memory implementation of Queue
  """
  alias BatchElixir.Environment
  alias BatchElixir.Server.Queue
  use GenServer

  @behaviour Queue

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: Environment.get(:queue_name))
  end

  def init(:ok) do
    {:ok, :queue.new()}
  end

  def push(item) do
    _call({:push, item})
  end

  def pop(number \\ 1) do
    _call({:pop, number})
  end

  defp _call(request) do
    GenServer.call(Environment.get(:queue_name), request)
  end

  def handle_call({:push, item}, _from, queue) do
    queue = :queue.in(item, queue)

    {:reply, :ok, queue}
  end

  def handle_call({:pop, number}, _from, queue) do
    {queue, remaining_queue} =
      queue
      |> is_queue_size_smaller_than_demand?(number)
      |> keep_intact_or_split_queue(queue, number)

    items = queue |> :queue.to_list()
    {:reply, items, remaining_queue}
  end

  defp keep_intact_or_split_queue(true, queue, _number) do
    {queue, :queue.new()}
  end

  defp keep_intact_or_split_queue(false, queue, number) do
    :queue.split(number, queue)
  end

  defp is_queue_size_smaller_than_demand?(queue, demand), do: :queue.len(queue) < demand
end
