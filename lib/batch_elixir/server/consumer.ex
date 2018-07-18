defmodule BatchElixir.Server.Consumer do
  @moduledoc false
  use GenStage
  alias BatchElixir.Environment
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.Serialisation
  require Logger

  @http_status_code_for_not_retry [400, 401, 404]
  
  def start_link(opts \\ []) do
    GenStage.start_link(
      __MODULE__,
      :ok,
      opts
    )
  end

  def init(:ok) do
    Logger.info(fn -> "Starting consumer" end)

    {:consumer, Environment.get(:queue_implementation),
     subscribe_to: [Environment.get(:producer_name)]}
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

    handle_action_result(
      Transactional.send(api_key, transactional),
      payload,
      event
    )
  end

  defp handle_action_result({:ok, token}, payload, _event) do
    Logger.debug(fn -> "Success token: #{token}, payload: #{payload}" end)
  end

  defp handle_action_result({:error, reason}, _payload, _event) do
    Logger.error(fn -> reason end)
  end

  defp handle_action_result({:error, status_code, reason}, payload, event) do
    is_code_allowed? = is_code_allowed_for_retry?(status_code)

    is_code_allowed?
    |> handle_http_error(reason, payload, event)
  end

  defp handle_http_error(true, reason, _payload, event) do
    Logger.error(fn -> reason end)
    Environment.get(:queue_implementation).push(event)
  end

  defp handle_http_error(false, reason, payload, _event) do
    Logger.error(fn -> ~s/"Error "#{reason}", payload: #{payload}, not retrying/ end)
  end

  defp is_code_allowed_for_retry?(status_code) do
    !Enum.member?(@http_status_code_for_not_retry, status_code)
  end
end
