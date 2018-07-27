defmodule BatchElixir.Server.ConsurmerTest do
  defmodule MockProducer do
    use GenStage

    def start_link do
      GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    def init(:ok) do
      {:producer, 0}
    end

    def handle_demand(_, _) do
      {:noreply, [], 0}
    end
  end

  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
  alias BatchElixir.Server.Consumer
  alias BatchElixir.Server.Queue.Memory
  use ExUnit.Case
  import Mock

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
    assert {:ok, stat} = BatchElixir.Stats.start_link()

    {:ok, pid} = Memory.start_link()

    on_exit(fn ->
      assert_down(pid)
      assert_down(stat)
    end)
  end

  defp generate_events(number_of_events) do
    for _ <- 1..number_of_events, do: {"api_key", :transactional, @body}
  end

  test "starting a consumer" do
    assert {:ok, mock_pid} = MockProducer.start_link()
    Application.put_env(:batch_elixir, :producer_name, mock_pid)
    assert {:ok, pid} = Consumer.start_link()

    GenStage.stop(pid)
    GenStage.stop(mock_pid)
  end

  test "send events without error" do
    with_mock Transactional,
      send: fn _api_key, _body -> {:ok, "test"} end do
      Consumer.handle_events(generate_events(3), nil, Memory)
      assert [] = Memory.pop()
    end
  end

  test "send events with errors that should be retried" do
    with_mock Transactional,
      send: fn _api_key, _body -> {:error, 500, "test"} end do
      events = generate_events(3)
      Consumer.handle_events(events, nil, Memory)
      assert ^events = Memory.pop(5)
    end
  end

  test "send events with http errors that should not be retried" do
    with_mock Transactional,
      send: fn _api_key, _body -> {:error, 400, "test"} end do
      Consumer.handle_events(generate_events(3), nil, Memory)
      assert [] = Memory.pop(5)
    end
  end

  test "send events with errors that should not be retried" do
    with_mock Transactional,
      send: fn _api_key, _body -> {:error, "test"} end do
      Consumer.handle_events(generate_events(3), nil, Memory)
      assert [] = Memory.pop(5)
    end
  end
end
