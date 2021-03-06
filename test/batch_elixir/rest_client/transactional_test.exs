defmodule BatchElixir.RestClient.TransactionalTest do
  alias BatchElixir.RestClient.Base
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
  use ExUnit.Case
  import Mock

  @body %Transactional{
    group_id: "test",
    message: %Message{body: "test"},
    recipients: %Recipients{tokens: ["test"]}
  }

  @error_message "oops"
  test "sending a notification" do
    with_mock Base,
      encode_body_and_request: fn body, _api_key, method, url ->
        assert body == @body

        assert method == :post
        assert url == "/transactional/send"

        {:ok, %{"token" => "test"}}
      end do
      assert {:ok, "test"} = Transactional.send("api_key", @body)
    end
  end

  test "sending to a notification with a response error" do
    with_mock Base,
      encode_body_and_request: fn _body, _api_key, _method, _url -> {:error, @error_message} end do
      assert {:error, @error_message} = Transactional.send("api_key", @body)
    end
  end
end
