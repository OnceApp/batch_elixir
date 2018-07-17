defmodule BatchElixir.RestClient.Transactional.Recipients do
  @moduledoc """
  Structure for recipients object in landing object
  """
  @derive [Poison.Encoder]
  @type t :: %__MODULE__{
          tokens: [String.t(), ...],
          custom_ids: [String.t(), ...],
          install_ids: [String.t(), ...]
        }
  defstruct [:tokens, :custom_ids, :install_ids]
end
