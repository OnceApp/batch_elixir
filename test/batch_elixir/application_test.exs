defmodule BatchElixir.ApplicationTest do
  alias BatchElixir.Server.Producer
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
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
    with_mock Transactional,
      send!: fn _qpi_key, _body -> "test" end do
      assert capture_log(fn ->
               {:ok, pid} = BatchElixir.Application.start(nil, nil)
               Producer.send_notification("api_key", @body, 1000)
               Process.sleep(100)
               Supervisor.stop(pid)
             end) =~ "Success"
    end
  end

  test "test producer -> consumer with an error" do
    {:ok, pid} = BatchElixir.Application.start(nil, nil)

    assert capture_log([level: :error], fn ->
             Producer.send_notification("api_key", @body, 1000)
             Process.sleep(500)
           end) != ""

    assert capture_log([level: :error], fn ->
             Producer.send_notification("api_key", @body, 1000)
             Process.sleep(500)
           end) != ""

    Supervisor.stop(pid)
  end
end
