defmodule BatchElixir.Server.Retry do
  @moduledoc """
  In memory implementation of Queue
  """
  use GenServer
  alias BatchElixir.Server.Producer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    schedule()
    {:ok, []}
  end

  def push(item) do
    _call({:push, item})
  end

  defp _call(request) do
    GenServer.call(__MODULE__, request)
  end

  def handle_call({:push, {event, attempts}}, _from, queue) do
    now = :os.system_time(:milli_seconds) + get_retry_interval()
    queue = [{event, attempts, now} | queue]

    {:reply, :ok, queue}
  end

  def handle_info(:retry, queue) do
    now = :os.system_time(:milli_seconds)
    send_events_that_should_be_retried(queue, now)

    new_state = new_state(queue, now)
    schedule()
    {:noreply, new_state}
  end

  defp send_events_that_should_be_retried(queue, now) do
    queue
    |> Stream.filter(&should_retry?(&1, now))
    |> Stream.map(fn {event, attempt, _} -> {event, attempt} end)
    |> Enum.into([])
    |> Producer.send_notifications()
  end

  defp new_state(queue, now) do
    queue
    |> Stream.filter(&(!should_retry?(&1, now)))
    |> Enum.into([])
  end

  defp should_retry?({_, _, retry}, now) when now >= retry, do: true
  defp should_retry?({_, _, _}, _now), do: false

  defp get_retry_interval, do: Application.get_env(:batch_elixir, :retry_interval, 100)
  def schedule, do: Process.send_after(self(), :retry, get_retry_interval())
end
