defmodule BatchElixir.Server.Consumer do
  use GenStage
  alias BatchElixir.RestClient.Transactional
  require Logger
  @producer_service BatchElixir.Server.Producer
  def start_link(_options \\ nil) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [@producer_service]}
  end

  def handle_events(events, _from, state) do
    events
    |> Enum.each(&do_action/1)

    {:noreply, [], state}
  end

  defp do_action({api_key, :transactional, transactional}) do
    payload = Poison.encode!(transactional)
    token = Transactional.send!(api_key, transactional)
    Logger.debug("Success token: #{token}, payload: #{payload}")
  end
end
