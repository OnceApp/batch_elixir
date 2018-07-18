defmodule BatchElixir.Server.Queue do
  @moduledoc """
  Behaviour for Queuing system
  """
  @callback push(item :: term) :: :ok | {:error, any}
  @callback pop(number :: pos_integer() | 1) :: [term]
end
