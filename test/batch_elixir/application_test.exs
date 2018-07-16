defmodule BatchElixir.ApplicationTest do
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
  alias BatchElixir.Server.Producer

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
      send: fn _qpi_key, _body -> {:ok, "test"} end do
      assert capture_log(fn ->
               {:ok, pid} = BatchElixir.Application.start(nil, nil)
               Producer.send_notification("api_key", @body)
               Process.sleep(100)
               Supervisor.stop(pid)
             end) =~ "Success"
    end
  end

  test "test producer -> consumer with an error" do
    {:ok, pid} = BatchElixir.Application.start(nil, nil)

    assert capture_log([level: :error], fn ->
             Producer.send_notification("api_key", @body)
             Process.sleep(500)
           end) =~ ~s/Error "Route not found"/

    assert capture_log([level: :error], fn ->
             Producer.send_notification("api_key", @body)
             Process.sleep(500)
           end) != ""

    Supervisor.stop(pid)
  end
end
