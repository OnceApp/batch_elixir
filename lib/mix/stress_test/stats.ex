defmodule StressTest.Stats do
  use GenServer
  alias BatchElixir.Stats

  def start_link(pid) do
    GenServer.start_link(__MODULE__, pid)
  end

  def handle_info(:dump, state) do
    result = Stats.dump()
    succeed = get_value(result["batch.requests.succeed"])
    failed = get_value(result["batch.requests.failed"])
    retried = get_value(result["batch.requests.retried"])
    value = succeed + failed + retried

    result
    |> do_action(state, value)
  end

  def init(pid) do
    schedule()
    {:ok, {pid, 0}}
  end

  defp do_action(_result, {_, _} = state, 0) do
    schedule()
    {:noreply, state}
  end

  defp do_action(result, {pid, current}, value) when current == value do
    send(pid, {:end, result})
    {:noreply, {pid, value}}
  end

  defp do_action(_result, {pid, _}, value) do
    send(pid, {:update, value})
    schedule()
    {:noreply, {pid, value}}
  end

  def schedule, do: Process.send_after(self(), :dump, 1_000)

  defp get_value(nil), do: 0
  defp get_value(value), do: value
end
