defmodule BatchElixir.RestClient.Transactional do
  @derive [Poison.Encoder]
  @moduledoc """

  """
  alias BatchElixir.RestClient.Base
  alias BatchElixir.RestClient.Transactional

  @type t :: %__MODULE__{
          group_id: String.t(),
          recipients: BatchElixir.RestClient.Transactional.Recipients.t(),
          message: BatchElixir.RestClient.Transactional.Message.t(),
          labels: [String.t(), ...],
          priority: String.t(),
          time_to_live: pos_integer(),
          gcm_collapse_key: map(),
          media: BatchElixir.RestClient.Transactional.Media.t(),
          deeplink: String.t(),
          sandbox: boolean(),
          wp_template: String.t(),
          custom_payload: String.t(),
          landing: BatchElixir.RestClient.Transactional.Landing.t()
        }
  @enforce_keys [:group_id, :recipients, :message]
  defstruct [
    :group_id,
    :recipients,
    :message,
    :labels,
    :priority,
    :media,
    :deeplink,
    :sandbox,
    :custom_payload,
    :landing,
    :time_to_live,
    :gcm_collapse_key,
    :wp_template
  ]

  @spec send(Transactional.t()) :: {:ok, String.t()} | {:error, any()}
  def send(transactional = %Transactional{}) do
    transactional
    |> Base.encode_body_and_execute_request(:post, "/transactional/send")
    |> handle_response
  end

  defp handle_response({:ok, body}), do: {:ok, body["token"]}
  defp handle_response(errored), do: errored
end
