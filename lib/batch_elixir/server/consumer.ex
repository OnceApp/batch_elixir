defmodule BatchElixir.Server.Consumer do
  @moduledoc false
  use GenStage
  alias BatchElixir.Environment
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.Serialisation
  alias BatchElixir.Server.Producer
  alias BatchElixir.Stats
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

    {:consumer, nil,
     subscribe_to: [{Environment.get(:producer_name), Environment.get(:consumer_options)}]}
  end

  def handle_events(events, _from, state) do
    parent = self()

    events
    |> Enum.each(&do_action(&1, parent))

    {:noreply, [], state}
  end

  defp get_max_attempts, do: Environment.get(:max_attempts)

  defp do_action({{api_key, :transactional, transactional} = event, attempts}, pid) do
    Stats.increment("batch.requests.total")

    payload =
      transactional
      |> Serialisation.structure_to_map()
      |> Serialisation.compact_map()
      |> Poison.encode!()

    result = transactional_send(api_key, transactional)

    handle_action_result(
      result,
      payload,
      event,
      attempts,
      pid
    )
  end

  def handle_info({:retry, event}, state) do
    Producer.send_notifications([event])
    {:noreply, [], state}
  end

  defp transactional_send(api_key, transactional) do
    Stats.measure("batch.requests.timing", fn ->
      Transactional.send(api_key, transactional)
    end)
  end

  defp handle_action_result({:ok, token}, payload, _event, _attempts, _pid) do
    Logger.debug(fn -> "Success token: #{token}, payload: #{payload}" end)
    Stats.increment("batch.requests.succeed")
  end

  defp handle_action_result(
         {:error, %HTTPoison.Error{reason: reason}},
         _payload,
         event,
         attempts,
         pid
       ) do
    Logger.error(fn -> "HTTP error: #{inspect(reason)}" end)
    retry_if_required(event, attempts, pid)
  end

  defp handle_action_result({:error, reason}, _payload, _event, _attempts, _pid) do
    Logger.error(fn -> inspect(reason) end)
    Stats.increment("batch.requests.failed")
  end

  defp handle_action_result({:error, status_code, reason}, payload, event, attempts, pid) do
    is_code_allowed? = is_code_allowed_for_retry?(status_code)

    is_code_allowed?
    |> handle_http_error(reason, payload, event, attempts, pid)
  end

  defp handle_http_error(true, reason, _payload, event, attempts, pid) do
    Logger.error(fn -> reason end)
    retry_if_required(event, attempts, pid)
  end

  defp handle_http_error(false, reason, payload, _event, _attempts, _pid) do
    Logger.error(fn -> ~s/Error "#{reason}", payload: #{payload}, not retrying/ end)
    Stats.increment("batch.requests.failed")
  end

  defp retry_if_required(event, attempts, pid) do
    attempts
    |> should_retry?
    |> handle_retry(event, attempts, pid)
  end

  defp should_retry?(attempts), do: attempts < get_max_attempts()

  defp handle_retry(true, event, attempts, pid) do
    Process.send_after(
      pid,
      {:retry, {event, attempts + 1}},
      get_retry_interval_in_milliseconds()
    )

    Stats.increment("batch.requests.retried")
  end

  defp handle_retry(false, _event, _attempts, _pid) do
    Stats.increment("batch.requests.failed")
  end

  defp get_retry_interval_in_milliseconds, do: Environment.get(:retry_interval_in_milliseconds)

  defp is_code_allowed_for_retry?(status_code) do
    !Enum.member?(@http_status_code_for_not_retry, status_code)
  end
end
