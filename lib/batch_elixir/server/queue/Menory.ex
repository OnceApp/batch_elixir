defmodule BatchElixir.Server.Queue.Memory do
  @moduledoc """
  In memory implementation of Queue
  """
  alias BatchElixir.Server.Queue
  use GenServer

  @behaviour Queue
  @queue_name Queue.queue_name()

  def start_link do
    case GenServer.start_link(__MODULE__, :ok, name: @queue_name) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Process.link(pid)
        {:ok, pid}
    end
  end

  def init(:ok) do
    {:ok, :queue.new()}
  end

  def push(item) do
    GenServer.call(@queue_name, {:push, item})
  end

  def pop(number \\ 1) do
    GenServer.call(@queue_name, {:pop, number})
  end

  def handle_call({:push, item}, _from, queue) do
    queue = :queue.in(item, queue)

    {:reply, :ok, queue}
  end

  def handle_call({:pop, number}, _from, queue) do
    {queue, remaining_queue} =
      case is_queue_size_smaller_than_demand?(queue, number) do
        true -> {queue, :queue.new()}
        false -> :queue.split(number, queue)
      end

    items = queue |> :queue.to_list()
    {:reply, items, remaining_queue}
  end

  defp is_queue_size_smaller_than_demand?(queue, demand), do: :queue.len(queue) < demand
end
