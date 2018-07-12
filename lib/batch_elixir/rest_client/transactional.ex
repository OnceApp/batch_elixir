defmodule BatchElixir.RestClient.Transactional do
  @derive [Poison.Encoder]
  @moduledoc """
  Module for interacting with the transactional API
  """
  alias BatchElixir.RestClient.Base

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

  @doc """
  Send an 1-to-1 interaction one or more users.

  ## Parameters

    * `transactional`: Request structure
    * `api_key`: API key of the application

  ## Examples

      iex>BatchElixir.RestClient.Transactional.send(%BatchElixir.RestClient.Transactional{}, "my_api_key")
      {:ok, "returned token"}

      iex>BatchElixir.RestClient.Transactional.send(%BatchElixir.RestClient.Transactional{}, "my_api_key")
      {:error, "something bad happend"}
  """
  @spec send(String.t(), __MODULE__.t()) :: {:ok, String.t()} | {:error, any()}
  def send(api_key, %__MODULE__{} = transactional) do
    transactional
    |> Base.encode_body_and_request(api_key, :post, "/transactional/send")
    |> handle_response
  end

  @doc """
  Same as send/2, but raises an exception in case of failure. Otherwise return the generated token
  """
  @spec send!(String.t(), __MODULE__.t()) :: String.t() | no_return()
  def send!(api_key, %__MODULE__{} = transactional) do
    case __MODULE__.send(api_key, transactional) do
      {:ok, token} -> token
      {:error, reason} -> raise reason
    end
  end

  defp handle_response({:ok, body}), do: {:ok, body["token"]}
  defp handle_response(errored), do: errored
end
