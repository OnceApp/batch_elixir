defmodule BatchElixir.Server.ProducerTest do
  alias BatchElixir.Server.Producer
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
  alias BatchElixir.Server.Consumer
  alias BatchElixir.Server.Queue.Memory
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureLog
  require Logger

  @body %Transactional{
    group_id: "test",
    message: %Message{body: "test", title: "test"},
    recipients: %Recipients{custom_ids: ["test"]}
  }

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  setup do
    Application.put_env(:batch_elixir, :producer_name, BatchElixir.Server.Producer)
    {:ok, pid} = Memory.start_link()
    {:ok, producer_pid} = Producer.start_link()

    on_exit(fn ->
      assert_down(pid)
      assert_down(producer_pid)
    end)
  end

  test "starting a producer" do
    assert(true)
  end
end
