defmodule BatchElixir do
  @default_deeplink Application.fetch_env!(:batch_elixir, :default_deeplink)
  @moduledoc """
  Documentation for BatchElixir.
  Rest client for interating with the **Batch** API.

  You have to define in your application this configuration:

    ```elixir
    config :batch_elixir,
      api_key: "your rest api key of batch",
      default_deeplink: "myapp://"
    ```

  """
  
  @doc """
  Send a notifcation to one or more users using the producers/consumers

  `custom_payload` can be either a string, structure or a map.
  If it's not provide or the value is nil, then no custom_payload will be include to the request
  """
  def send_notication(
        api_key,
        group_id,
        custom_ids,
        title,
        message,
        deeplink \\ @default_deeplink,
        custom_payload \\ nil
      )

  def send_notication(api_key, group_id, custom_ids, title, message, deeplink, nil) do
    structure = create_transactional_structure(group_id, custom_ids, title, message, deeplink)

    _send_notication(api_key, structure)
  end

  def send_notication(api_key, group_id, custom_ids, title, message, deeplink, custom_payload)
      when is_map(custom_payload) do
    custom_payload =
      custom_payload
      |> BatchElixir.Utils.structure_to_map()
      |> Poison.encode!()

    send_notication(api_key, group_id, custom_ids, title, message, deeplink, custom_payload)
  end

  def send_notication(api_key, group_id, custom_ids, title, message, deeplink, custom_payload)
      when is_binary(custom_payload) do
    structure = create_transactional_structure(group_id, custom_ids, title, message, deeplink)
    structure = %BatchElixir.RestClient.Transactional{structure | custom_payload: custom_payload}
    _send_notication(api_key, structure)
  end

  defp _send_notication(api_key, transactional) do
    BatchElixir.Server.Producer.send_notification(api_key, transactional)
  end

  defp create_transactional_structure(group_id, custom_ids, title, message, deeplink) do
    message = %BatchElixir.RestClient.Transactional.Message{title: title, body: message}
    recipients = %BatchElixir.RestClient.Transactional.Recipients{custom_ids: custom_ids}

    %BatchElixir.RestClient.Transactional{
      group_id: group_id,
      message: message,
      recipients: recipients,
      deeplink: deeplink
    }
  end
end
