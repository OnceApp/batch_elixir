defmodule BehaviourTestTest do
  alias BehaviourTest, as: Server
  use ExUnit.Case
  use Hound.Helpers
  @group_id "test"

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  setup_all do
    {:ok, pid} = Server.start(nil, nil)

    on_exit(fn ->
      assert_down(pid)
    end)
  end

  hound_session(
    additional_capabilities: %{
      acceptInsecureCerts: true,
      acceptSslCerts: true,
      databaseEnabled: true,
      webStorageEnabled: true,
      javascriptEnabled: true,
      "moz:firefoxOptions": %{
        args: ["-headless"],
        prefs: %{"permissions.default.desktop-notification": 1}
      }
    }
  )

  test "the truth" do
    navigate_to("https://localhost:3000/index.html")
    assert execute_script("return typeof navigator.serviceWorker !== 'undefined'")
    get_customer_id() |> send_notifications
    recieved_notifications()
  end

  defp get_customer_id do
    assert {:ok, customer} = exists?(:id, "customer", 3)
    id = inner_text(customer)
    assert {:ok, _} = exists?(:id, "load", 3)
    :timer.sleep(15_000)
    id
  end

  defp send_notifications(customer_id) do
    range = 1..5

    range
    |> Enum.each(fn i ->
      assert :ok =
               BatchElixir.send_notication(
                 :web,
                 @group_id,
                 [customer_id],
                 "test #{i}",
                 "msg #{i}"
               )
    end)
  end

  defp recieved_notifications do
    assert {:ok, container} = exists?(:css, "ul#notifications", 5)
    assert {:ok, _} = exists_all?(container, :tag, "li", 10)
  end

  defp exists?(type, value, retries) when retries > 1 do
    handle_result(search_element(type, value), fn _ ->
      :timer.sleep(1_000)
      exists?(type, value, retries - 1)
    end)
  end

  defp exists?(type, value, _retries) do
    handle_result(search_element(type, value), fn error ->
      error
    end)
  end

  defp exists_all?(parent, type, value, retries) when retries > 1 do
    handle_result(search_within_element(parent, type, value), fn _ ->
      :timer.sleep(1_000)
      exists_all?(parent, type, value, retries - 1)
    end)
  end

  defp exists_all?(parent, type, value, _retries) do
    handle_result(search_within_element(parent, type, value), fn error ->
      error
    end)
  end

  defp handle_result({:ok, _} = result, _func), do: result

  defp handle_result({:error, map}, _func) when is_map(map),
    do: convert_false_error_to_success(map)

  defp handle_result(error, func), do: func.(error)

  defp convert_false_error_to_success(map) do
    element_id = map |> Map.values() |> hd
    {:ok, %Hound.Element{uuid: element_id}}
  end
end
