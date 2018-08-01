defmodule BatchElixir.Server.ProducerTest do
  alias BatchElixir.Server.Producer
  use ExUnit.Case

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  setup do
    Application.put_env(:batch_elixir, :producer_name, BatchElixir.Server.Producer)
    {:ok, producer_pid} = Producer.start_link()

    on_exit(fn ->
      assert_down(producer_pid)
    end)
  end

  test "starting a producer" do
    assert(true)
  end
end
