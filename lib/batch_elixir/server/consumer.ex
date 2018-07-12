defmodule BatchElixir.Server.Consumer do
  use GenStage
  alias BatchElixir.RestClient.Transactional
  require Logger
  @producer_service Application.fetch_env(:batch_elixir, :producer)
  def start_link(_options \\ nil) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    case @producer_service do
      {:ok, producer} ->
        {:consumer, :ok, subscribe_to: [producer]}

      :error ->
        {:stop, "Producer not defined"}
    end
  end

  def handle_events(events, _from, state) do
    events
    |> Enum.each(&do_action/1)

    {:noreply, [], state}
  end

  defp do_action({:transactional, transactional}) do
    payload = Poison.encode!(transactional)
    token = Transactional.send!(transactional)
    Logger.debug("Success token: #{token}, payload: #{payload}")
  end
end
