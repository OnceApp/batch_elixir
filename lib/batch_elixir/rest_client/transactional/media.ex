defmodule BatchElixir.RestClient.Transactional.Media do
  @derive [Poison.Encoder]
  @moduledoc """
    Helper for creating transactional message object
  """
  @type t :: %__MODULE__{
          icon: String.t(),
          picture: String.t(),
          audio: String.t(),
          video: String.t()
        }
  defstruct [:icon, :picture, :audio, :video]
end
