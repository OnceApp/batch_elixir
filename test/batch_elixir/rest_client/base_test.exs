defmodule BatchElixir.RestClient.BaseTest do
  alias BatchElixir.RestClient.Base
  use ExUnit.Case
  import Mock
  @body %{"message" => "test"}
  @body_json Poison.encode!(@body)

  @success_request_body %{"token" => "success"}
  @success_request_body_json Poison.encode!(@success_request_body)

  @error_message "oops"
  @failed_request_body %{"message" => @error_message}
  @failed_request_body_json Poison.encode!(@failed_request_body)

  @url "/mock"

  test "execute an successful request using a body" do
    with_mock HTTPoison,
      request: fn _method, _url, body, _headers ->
        assert body == @body_json

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: @success_request_body_json
         }}
      end do
      assert {:ok, @success_request_body} =
               Base.encode_body_and_request(@body, "api_key", :post, @url)
    end
  end

  test "execute an successful request not using a body" do
    with_mock HTTPoison,
      request: fn _method, _url, _body, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: @success_request_body_json
         }}
      end do
      assert {:ok, @success_request_body} = Base.request("api_key", :post, @url)
    end
  end

  test "execute an unsuccessful request using a body" do
    with_mock HTTPoison,
      request: fn _method, _url, body, _headers ->
        assert body == @body_json

        {:ok,
         %HTTPoison.Response{
           status_code: 500,
           body: @failed_request_body_json
         }}
      end do
      assert {:error, 500, @error_message} =
               Base.encode_body_and_request(@body, "api_key", :post, @url)
    end
  end

  test "execute an errored request" do
    error = %HTTPoison.Error{reason: @error_message}

    with_mock HTTPoison, request: fn _method, _url, _body, _headers -> {:error, error} end do
      assert {:error, ^error} = Base.request("api_key", :get, @url)
    end
  end
end
