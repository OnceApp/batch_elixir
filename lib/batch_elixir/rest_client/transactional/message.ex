defmodule BatchElixir.RestClient.Transactional.Message do
  @derive [Poison.Encoder]
  @moduledoc """
  Helper for creating transactional recipients object
  """
  @type t :: %__MODULE__{
          body: String.t(),
          title: String.t()
        }
  @enforce_keys [:body]
  defstruct [:body, :title]
end
