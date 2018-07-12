defmodule BatchElixir.RestClient.Transactional.Message do
  @moduledoc """
  Structure for message object in landing object
  """
  @derive [Poison.Encoder]
  @type t :: %__MODULE__{
          body: String.t(),
          title: String.t()
        }
  @enforce_keys [:body]
  defstruct [:body, :title]
end
