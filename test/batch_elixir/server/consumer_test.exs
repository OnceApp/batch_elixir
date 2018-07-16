defmodule BatchElixir.RestClient.ConsurmerTest do
  alias BatchElixir.Server.Producer
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
  alias BatchElixir.Server.Consumer
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureLog
  require Logger

  @body %Transactional{
    group_id: "test",
    message: %Message{body: "test", title: "test"},
    recipients: %Recipients{custom_ids: ["test"]}
  }
  @queue_implementation Application.fetch_env!(:batch_elixir, :queue_implentation)
  test "test producer -> consumer" do
    with_mock Transactional, [:passthrough], send: fn _body, _api_key -> {:ok, "test"} end do
      assert capture_log(fn ->
               {:ok, queue} = @queue_implementation.start_link()
               {:ok, producer} = Producer.start_link()
               {:ok, _} = Consumer.start_link()
               Producer.send_notification("api_key", @body)
               Process.sleep(100)
               GenStage.stop(producer)
               GenServer.stop(queue)
             end) =~ "Success"
    end
  end

  test "test producer -> consumer with an error" do
    {:ok, queue} = @queue_implementation.start_link()
    {:ok, producer} = Producer.start_link()
    {:ok, _} = Consumer.start_link()
    Producer.send_notification("api_key", @body)
    Process.sleep(100)
    GenStage.stop(producer)
    GenServer.stop(queue)
  end

  test "test consumer after have sent the data" do
    with_mock Transactional,
      send: fn _api_key, _body -> {:ok, "test"} end do
      assert capture_log(fn ->
               {:ok, queue} = @queue_implementation.start_link()
               {:ok, producer} = Producer.start_link()
               Producer.send_notification("api_key", @body)
               {:ok, _} = Consumer.start_link()
               Process.sleep(100)
               GenStage.stop(producer)
               GenServer.stop(queue)
             end) =~ "Success"
    end
  end

  test "test sending timeout" do
    with_mock Transactional,
      send: fn _api_key, _body -> {:ok, "test"} end do
      {:ok, queue} = @queue_implementation.start_link()
      {:ok, producer} = Producer.start_link()
      Producer.send_notification("api_key", @body)
      Process.sleep(100)
      GenStage.stop(producer)
      GenServer.stop(queue)
    end
  end
end
