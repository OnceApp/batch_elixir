defmodule BatchElixir.Server.Consumer do
  @moduledoc false
  use GenStage
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.Serialisation
  require Logger
  @producer_service {:global, BatchProducer}
  @queue_implementation Application.fetch_env!(:batch_elixir, :queue_implentation)
  @http_status_code_for_not_retry [400, 401, 404]
  def start_link(_options \\ nil) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info(fn -> "Starting consumer" end)
    {:consumer, :ok, subscribe_to: [@producer_service]}
  end

  def handle_events(events, _from, state) do
    events
    |> Enum.each(&do_action/1)

    {:noreply, [], state}
  end

  defp do_action({api_key, :transactional, transactional} = event) do
    payload =
      transactional
      |> Serialisation.structure_to_map()
      |> Serialisation.compact_map()
      |> Poison.encode!()

    case Transactional.send(api_key, transactional) do
      {:ok, token} ->
        Logger.debug(fn -> "Success token: #{token}, payload: #{payload}" end)

      {:error, status_code, reason} ->
        handle_http_error(event, {status_code, reason}, payload)

      {:error, reason} ->
        Logger.error(fn -> reason end)
        @queue_implementation.push(event)
    end
  end

  defp is_code_allowed_for_retry?(status_code) do
    !Enum.member?(@http_status_code_for_not_retry, status_code)
  end

  defp handle_http_error(event, {status_code, reason}, payload) do
    case is_code_allowed_for_retry?(status_code) do
      false ->
        Logger.error(fn -> ~s/"Error "#{reason}", payload: #{payload}, not retrying/ end)

      true ->
        Logger.error(fn -> reason end)
        @queue_implementation.push(event)
    end
  end
end
