defmodule BatchElixir.RestClient.Transactional.Recipients do
  @derive [Poison.Encoder]
  @moduledoc """
  Helper for creating transactional recipients object
  """
  @type t :: %__MODULE__{
          tokens: [String.t(), ...],
          custom_ids: [String.t(), ...],
          install_ids: [String.t(), ...]
        }
  defstruct [:tokens, :custom_ids, :install_ids]
end
