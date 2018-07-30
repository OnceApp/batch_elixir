defmodule StressTest.Result do
  use Timex

  @header [
    "Notifications",
    "Total",
    "Succeed",
    "Failed",
    "Retried",
    "Lost",
    "Mean latency"
  ]
  @size length(@header)
  @accumulator for _ <- 1..@size, do: 0
  def handle_receive(max) do
    receive do
      {:update, value} ->
        handle_update(value, max)

      {:end, result} ->
        handle_end(result, max)
    end
  end

  defp handle_update(_value, max) do
    handle_receive(max)
  end

  defp handle_end(result, max) do
    total = get_value(result.count["batch.requests.total"])
    succeed = get_value(result.count["batch.requests.succeed"])
    failed = get_value(result.count["batch.requests.failed"])
    retried = get_value(result.count["batch.requests.retried"])
    timing = get_value(result.timing["batch.requests.timing"])
    lost = max - (succeed + failed)

    [max, total, succeed, failed, retried, lost, timing / total]
  end

  defp get_value(nil), do: 0
  defp get_value(value), do: value

  defp calculate_average(results) when length(results) == 1 do
    results
  end

  defp calculate_average(results) do
    average =
      results
      |> sum_results()
      |> calculate_timing_average(length(results))

    results ++ [average]
  end

  defp sum_results(results) do
    results
    |> Enum.reduce(@accumulator, &_sum_results/2)
  end

  defp _sum_results(
         [
           max,
           total,
           succeed,
           failed,
           retried,
           lost,
           timing
         ],
         [
           acc_max,
           acc_total,
           acc_succeed,
           acc_failed,
           acc_retried,
           acc_lost,
           acc_timing
         ]
       ) do
    [
      max + acc_max,
      total + acc_total,
      succeed + acc_succeed,
      failed + acc_failed,
      retried + acc_retried,
      lost + acc_lost,
      timing + acc_timing
    ]
  end

  defp calculate_timing_average(
         [
           max,
           total,
           succeed,
           failed,
           retried,
           lost,
           timing
         ],
         size
       ) do
    [
      max / size,
      total / size,
      succeed / size,
      failed / size,
      retried / size,
      lost / size,
      timing / size
    ]
  end

  def print_result(rows) do
    rows
    |> calculate_average()
    |> Enum.map(&humanize_results/1)
    |> TableRex.quick_render!(@header)
    |> IO.puts()
  end

  defp humanize_results([
         max,
         total,
         succeed,
         failed,
         retried,
         lost,
         timing
       ]) do
    succeed_percent = :io_lib.format("~.2f", [succeed / max * 100])
    failed_percent = :io_lib.format("~.2f", [failed / max * 100])
    lost_percent = :io_lib.format("~.2f", [lost / max * 100])

    timing =
      timing
      |> Duration.from_milliseconds()
      |> Timex.format_duration(:humanized)

    [
      max,
      total,
      "#{succeed} (#{succeed_percent}%)",
      "#{failed} (#{failed_percent}%)",
      retried,
      "#{lost} (#{lost_percent}%)",
      timing
    ]
  end
end
