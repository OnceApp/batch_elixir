defmodule BatchElixir do
  @default_deeplink Application.fetch_env!(:batch_elixir, :default_deeplink)
  @moduledoc """
  Documentation for BatchElixir.
  """
  def send_notication(
        group_id,
        custom_ids,
        title,
        message,
        deeplink \\ @default_deeplink,
        custom_payload \\ nil
      )

  def send_notication(group_id, custom_ids, title, message, deeplink, nil) do
    structure = create_transactional_structure(group_id, custom_ids, title, message, deeplink)
    _send_notication(structure)
  end

  def send_notication(group_id, custom_ids, title, message, deeplink, custom_payload)
      when is_map(custom_payload) do
    custom_payload =
      custom_payload
      |> BatchElixir.Utils.structure_to_map()
      |> Poison.encode!()

    send_notication(group_id, custom_ids, title, message, deeplink, custom_payload)
  end

  def send_notication(group_id, custom_ids, title, message, deeplink, custom_payload)
      when is_binary(custom_payload) do
    structure = create_transactional_structure(group_id, custom_ids, title, message, deeplink)
    structure = %BatchElixir.RestClient.Transactional{structure | custom_payload: custom_payload}
    _send_notication(structure)
  end

  defp _send_notication(transactional) do
    BatchElixir.Server.Producer.send_event({:transactional, transactional})
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
