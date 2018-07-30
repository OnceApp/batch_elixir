defmodule BatchElixir.Server.Queue.RetryTest do
  alias BatchElixir.Server.Producer
  alias BatchElixir.Server.Retry
  use ExUnit.Case
  import Mock

  test "Add 5 items to queue" do
    Application.put_env(:batch_elixir, :retry_interval_in_milliseconds, 1_000)
    {:ok, pid} = Retry.start_link()

    assert 1..5
           |> Enum.map(&{&1, 1})
           |> Enum.map(&Retry.push/1)
           |> Enum.all?(&(:ok == &1))

    GenServer.stop(pid)
  end

  test "Removing elements with the default value" do
    with_mock(
      Producer,
      send_notifications: fn events ->
        result = for i <- 1..5, do: {i, 1}
        assert [] = events
      end
    ) do
      Application.put_env(:batch_elixir, :retry_interval_in_milliseconds, 1)
      {:ok, pid} = Retry.start_link()
      1..5 |> Enum.map(&{&1, 0}) |> Enum.each(&Retry.push/1)
      GenServer.stop(pid)
    end
  end
end
