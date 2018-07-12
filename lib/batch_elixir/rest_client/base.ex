defmodule BatchElixir.RestClient.Base do
  @batch_api_key Application.fetch_env!(:batch_elixir, :api_key)
  @batch_rest_api_key Application.fetch_env!(:batch_elixir, :rest_api_key)
  @api_version "1.1"
  @api_uri "https://api.batch.com/#{@api_version}/"
  @http_headers ["Content-Type": "application/json", "X-Authorization": @batch_rest_api_key]
  defp create_full_api_uri(path), do: @api_uri <> @batch_api_key <> path

  def execute_request(body \\ "", method, path) do
    url = create_full_api_uri(path)

    HTTPoison.request(method, url, body, @http_headers)
    |> handle_response
  end

  def encode_body_and_execute_request(body, method, path) do
    body
    |> BatchElixir.Utils.structure_to_map
    |> BatchElixir.Utils.compact_map
    |> Poison.encode!()
    |> execute_request(method, path)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}})
       when status_code < 400 do
    Poison.decode(body)
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    {:error, retrieve_error_message_from_body(body)}
  end

  defp handle_response({:error, _} = errored), do: errored

  defp retrieve_error_message_from_body(body_as_string) do
    body = body_as_string |> Poison.decode!()
    body["message"]
  end
end
