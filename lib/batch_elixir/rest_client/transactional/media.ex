defmodule BatchElixir.RestClient.Transactional.Media do
  @moduledoc """
  Structure for media object in landing object
  """
  @derive [Poison.Encoder]
  @type t :: %__MODULE__{
          icon: String.t(),
          picture: String.t(),
          audio: String.t(),
          video: String.t()
        }
  defstruct [:icon, :picture, :audio, :video]
end
