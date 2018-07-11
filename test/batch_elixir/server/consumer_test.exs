defmodule BatchElixir.RestClient.ConsurmerTest do
  alias BatchElixir.Server.Producer
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
  alias BatchElixir.Server.Consumer
  use ExUnit.Case
  import Mock
require Logger
  @body %Transactional{
    group_id: "test",
    message: %Message{body: "test"},
    recipients: %Recipients{tokens: ["test"]}
  }


  test "test producer -> consumer" do
    with_mock Transactional,
      send: fn _body ->
        {:ok, "test"}
      end do
      {:ok, producer} = Producer.start_link()
      {:ok, _} = Consumer.start_link()
      Producer.send_data({:transactional,@body},1)
      GenStage.stop producer
    end
  end
  test "test producer -> consumer with an error" do
    with_mock Transactional,
      send: fn _body ->
        {:error, "error"}
      end do
      {:ok, producer} = Producer.start_link()
      {:ok, _} = Consumer.start_link()
      Producer.send_data({:transactional,@body},1)
      GenStage.stop producer
    end
  end
  test "test producer -> consumer *3" do
    with_mock Transactional,
      send: fn _body ->
        {:ok, "test"}
      end do
      {:ok, producer} = Producer.start_link()
      {:ok, _} = Consumer.start_link()
      Producer.send_data({:transactional,@body},1)
      GenStage.stop producer
    end
  end

  test "test producer without consumer " do
    with_mock Transactional,
      send: fn _body ->
        {:ok, "test"}
      end do
      {:ok, producer} = Producer.start_link()
      Producer.send_data({:transactional,@body},1)
      {:ok, _} = Consumer.start_link()
      Process.sleep(100)
      GenStage.stop producer
    end
  end
end
