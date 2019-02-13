defmodule BatchElixir.RestClient.Base do
  alias BatchElixir.Environment
  alias BatchElixir.Serialisation

  @moduledoc """
  Rest client for interating with the **Batch** API.
  """
  defp generate_http_headers,
    do: [
      "Content-Type": "application/json",
      "X-Authorization": Environment.get(:rest_api_key)
    ]

  defp create_full_api_uri(api_key, path), do: Environment.get(:batch_url) <> api_key <> path

  @doc """
  Send an HTTP request to an endpoint of *Batch* API.

  ## Parameters

    * `body`: Body sent in the request.
    For GET the body MUST be ""
    * `api_key`: API key of your application
    * `method`: HTTP method, from one of **:get**, **:post**, **:delete**
    * `path`: Desired endpoint start with **/**

  ## Examples

    BatchElixir.RestClient.Base.request(~s/{"group_id": "test"}/, "my_rest_api_key", :post, "/transactional/send")
  """

  def request(body, api_key, method, path) do
    url = create_full_api_uri(api_key, path)

    response = HTTPoison.request(method, url, body, generate_http_headers())
    handle_response(response)
  end

  def request(api_key, :get, path) do
    request("", api_key, :get, path)
  end

  @doc """
  Encode a body in JSON and send an HTTP request to an endpoint of *Batch* API.

  ## Parameters

    * `body`: Body sent in the request.
    * `api_key`: API key of your application
    * `method`: HTTP method, from one of **:get**, **:post**, **:delete**
    * `path`: Desired endpoint start with **/**

  ## Examples

    BatchElixir.RestClient.Base.request(%{"group_id" => "test"}, "my_rest_api_key", :post, "/transactional/send")
  """
  def encode_body_and_request(body, api_key, method, path) do
    body
    |> Serialisation.structure_to_map()
    |> Serialisation.compact_map()
    |> Poison.encode!()
    |> request(api_key, method, path)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}})
       when status_code < 400 do
    Poison.decode(body)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    {:error, status_code, retrieve_error_message_from_body(body)}
  end

  defp handle_response({:error, _} = errored), do: errored

  defp retrieve_error_message_from_body(body_as_string) do
    with {:ok, body} <- Poison.decode(body_as_string) do
      body["message"]
    else
      _ -> body_as_string
    end
  end
end
