defmodule BatchElixir do
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
  alias BatchElixir.Serialisation
  alias BatchElixir.Server.Producer

  @moduledoc """
  Documentation for BatchElixir.
  Rest client for interating with the **Batch** API.

  You have to define in your application this configuration:

    ```elixir
    config :batch_elixir,
      rest_api_key: "rest api key", # Required, if not provided the application fail to start
      devices: [web: "sdk key", ios: "sdk key", ...], # List of devices that the notification can use. The key name are up to you
      default_deeplink: "myapp://",
      producer_name: BatchElixir.Server.Producer, # Default, name of the producer is BatchElixir.Server.Producer
      consumer_options: [], # Default to empty, extra options like mix/max demand for Genstage
      producer_options: [], # extra options for GenStage as producer. Typically [buffer_size: 10_000]
      batch_url: "https://api.batch.com/1.1/", # Base url of batch api
      retry_interval_in_milliseconds: 1_000, # Interval between each failed requests
      max_attempts: 3, # Maximum attempts of failed requests
      number_of_consumers: 1, # Number of consumers to pop. By default is 1
      stats_driver: BatchElixir.Stats.Memory # BatchElixir.Stats.Memory For In memory stats or BatchElixir.Stats.Statix to send to datadog via Statix
    ```

  """

  @doc """
  Send a notifcation to one or more users using the producers/consumers

  `custom_payload` can be either a string, structure or a map.
  If it's not provide or the value is nil, then no custom_payload will be include to the request.
  If the API key for the `device` does not exists return `{:error, reason}`,
  otherwise returns `:ok`.
  """
  @spec send_notication(
          device :: atom(),
          group_id :: String.t(),
          custom_ids :: [String.t()],
          title :: String.t(),
          message :: String.t(),
          deeplink :: String.t(),
          custom_payload :: String.t() | nil
        ) :: :ok | {:error, String.t()}
  def send_notication(
        device,
        group_id,
        custom_ids,
        title,
        message,
        deeplink \\ nil,
        custom_payload \\ nil
      )

  def send_notication(device, group_id, custom_ids, title, message, nil, custom_payload) do
    send_notication(
      device,
      group_id,
      custom_ids,
      title,
      message,
      get_default_deeplink(),
      custom_payload
    )
  end

  def send_notication(device, group_id, custom_ids, title, message, deeplink, nil) do
    structure = create_transactional_structure(group_id, custom_ids, title, message, deeplink)
    _send_notication(device, structure)
  end

  def send_notication(device, group_id, custom_ids, title, message, deeplink, custom_payload)
      when is_map(custom_payload) do
    custom_payload =
      custom_payload
      |> Serialisation.structure_to_map()
      |> Poison.encode!()

    send_notication(device, group_id, custom_ids, title, message, deeplink, custom_payload)
  end

  def send_notication(device, group_id, custom_ids, title, message, deeplink, custom_payload)
      when is_binary(custom_payload) do
    structure = create_transactional_structure(group_id, custom_ids, title, message, deeplink)
    structure = %Transactional{structure | custom_payload: custom_payload}
    _send_notication(device, structure)
  end

  defp _send_notication(device, transactional) do
    _send_notication_with_api_key(devices()[device], transactional, device)
  end

  defp _send_notication_with_api_key(nil, _transactional, device) do
    {:error, "No API key found for: #{device}"}
  end

  defp _send_notication_with_api_key(api_key, transactional, _device) do
    Producer.send_notification(api_key, transactional)
    :ok
  end

  defp create_transactional_structure(group_id, custom_ids, title, message, deeplink) do
    message = %Message{title: title, body: message}
    recipients = %Recipients{custom_ids: custom_ids}

    %Transactional{
      group_id: group_id,
      message: message,
      recipients: recipients,
      deeplink: deeplink
    }
  end

  defp get_default_deeplink, do: Application.fetch_env!(:batch_elixir, :default_deeplink)
  defp devices, do: Application.get_env(:batch_elixir, :devices, [])
end
