defmodule StressTest.CLI do
  alias StressTest.Config
  alias StressTest.ProgressBar
  alias StressTest.Result
  use Timex

  def main(args \\ []) do
    # ANSI.print(["Hello", :red, :bright, " World", :reset, "!"])

    args
    |> parse
    |> maybe_setup_from_json
    |> start
  end

  defp parse(args) do
    OptionParser.parse(args)
  end

  defp maybe_setup_from_json({args, params, _}) do
    args
    |> Enum.map(&do_arg_action/1)
    |> Enum.filter(&(&1 != nil))

    {args, params}
  end

  defp do_arg_action({:config, config}) do
    Config.setup(config)
    nil
  end

  defp do_arg_action({:max, _} = arg) do
    arg
  end

  defp do_arg_action({:threshold, _} = arg) do
    arg
  end

  defp do_arg_action({:start, _} = arg) do
    arg
  end

  defp do_arg_action(_) do
    nil
  end

  defp start(nil) do
    IO.puts("""
    USAGE: mix benchmark max notification...[options]
    OPTIONS
    --config configuration json file
    --max max consumer
    """)
  end

  defp start(params) do
    {:ok, _} = Application.ensure_all_started(:timex)
    {:ok, _} = Application.ensure_all_started(:table_rex)
    now = Duration.now()

    params
    |> run_iterations
    |> Result.print_result()

    IO.puts("Test duration:")

    Duration.elapsed(now)
    |> Timex.format_duration(:humanized)
    |> IO.puts()
  end

  defp run_iterations({args, [max, iterations]}) do
    threshold = String.to_float(get_with_default(args, :threshold, "0.0")) * 100

    ProgressBar.render_spinner(
      "Load charge running: #{iterations} iteration(s), #{max} notifications per iteration, #{
        threshold
      }% chance to have a failed request",
      "#{iterations} iteration(s) done",
      fn -> _run_iterations(args, max, iterations) end
    )
  end

  defp _run_iterations(args, max, iterations) do
    max_consumer = String.to_integer(get_with_default(args, :max, "1"))
    threshold = String.to_float(get_with_default(args, :threshold, "0.0"))
    max = String.to_integer(max)
    iterations = String.to_integer(iterations)
    for _ <- 1..iterations, do: run_interation(max, max_consumer, threshold)
  end

  defp get_with_default(list, key, default), do: _get_with_default(list[key], default)
  defp _get_with_default(nil, default), do: default
  defp _get_with_default(value, _default), do: value

  defp start_applications(consumers) do
    Config.setup(number_of_consumers: consumers)
    {:ok, app_pid} = BatchElixir.Application.start(nil, nil)
    {:ok, stats_pid} = StressTest.Stats.start_link(self())
    {app_pid, stats_pid}
  end

  defp run_interation(max, consumers, threshold) do
    {app_pid, stats_pid} = start_applications(consumers)
    send_notifications(max, threshold)
    result = Result.handle_receive(max)
    :ok = Supervisor.stop(app_pid)
    :ok = GenServer.stop(stats_pid)
    result
  end

  defp send_notifications(max, threshold) do
    for _ <- 1..max do
      group_id = get_group_id(:rand.uniform(), threshold)
      :ok = BatchElixir.send_notication(:web, group_id, ["test"], "test", "test")
    end
  end

  defp get_group_id(rand, threshold) when rand >= threshold, do: "test"
  defp get_group_id(_rand, _threshold), do: "fail"
end
