defmodule BatchElixir.Server.Queue do
  @moduledoc """
  Behaviour for Queuing system
  """
  @callback push(item :: term) :: :ok | {:error, any}
  @callback pop(number :: pos_integer() | 1) :: [term]

  def queue_name do
    case Application.fetch_env(:batch_elixir, :queue_name) do
      {:ok, name} -> name
      _ -> {:global, BatchQueue}
    end
  end
end
