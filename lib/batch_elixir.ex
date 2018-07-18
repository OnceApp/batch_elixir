defmodule BatchElixir do
  alias BatchElixir.RestClient.Transactional
  alias BatchElixir.RestClient.Transactional.Message
  alias BatchElixir.RestClient.Transactional.Recipients
  alias BatchElixir.Serialisation
  alias BatchElixir.Server.Producer
  @default_deeplink Application.fetch_env!(:batch_elixir, :default_deeplink)
  @devices Application.get_env(:batch_elixir, :devices)

  @moduledoc """
  Documentation for BatchElixir.
  Rest client for interating with the **Batch** API.

  You have to define in your application this configuration:

    ```elixir
    config :batch_elixir,
      devices: "your rest api key of batch",
      default_deeplink: "myapp://"
    ```

  """

  @doc """
  Send a notifcation to one or more users using the producers/consumers

  `custom_payload` can be either a string, structure or a map.
  If it's not provide or the value is nil, then no custom_payload will be include to the request
  """
  def send_notication(
        device,
        group_id,
        custom_ids,
        title,
        message,
        deeplink \\ @default_deeplink,
        custom_payload \\ nil
      )

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
    _send_notication_with_api_key(@devices[device], transactional, device)
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
end
