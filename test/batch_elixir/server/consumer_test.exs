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
  test "test producer -> consumer" do
    with_mock Transactional, [:passthrough], send: fn _body, _api_key -> {:ok, "test"} end do
      assert capture_log(fn ->
               {:ok, producer} = Producer.start_link()
               {:ok, _} = Consumer.start_link()
               Producer.send_notification("api_key", @body, 1000)
               Process.sleep(100)
               GenStage.stop(producer)
             end) =~ "Success"
    end
  end

  test "test producer -> consumer with an error" do
    {:ok, producer} = Producer.start_link()
    {:ok, _} = Consumer.start_link()
    Producer.send_notification("api_key", @body, 1000)
    Process.sleep(100)
    GenStage.stop(producer)
  end

  test "test consumer after have sent the data" do
    with_mock Transactional,
      send!: fn _api_key, _body -> "test" end do
      assert capture_log(fn ->
               {:ok, producer} = Producer.start_link()
               Producer.send_notification("api_key", @body, 1000)
               {:ok, _} = Consumer.start_link()
               Process.sleep(100)
               GenStage.stop(producer)
             end) =~ "Success"
    end
  end

  test "test sending timeout" do
    with_mock Transactional,
      send!: fn _api_key, _body -> "test" end do
      {:ok, producer} = Producer.start_link()
      Producer.send_notification("api_key", @body, 10)
      Process.sleep(100)
      GenStage.stop(producer)
    end
  end
end
