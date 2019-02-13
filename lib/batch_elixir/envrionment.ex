defmodule BatchElixir.Environment do
  @moduledoc """
  Wrapper module to access to the application environment value
  """
  @doc """
  Get the value from a key.

  Return nil if the key does not exist in the application environment.
  Otherwise return the value.
  """
  @spec get(atom()) :: any() | nil
  def get(key), do: Application.get_env(:batch_elixir, key)

  @doc """
  Ensure they the key exists.
  Return `:ok` if the key exists, otherwise it will return `{:error,reason}` for undefined key.
  """
  @spec ensure(atom()) :: :ok | {:error, String.t()}
  def ensure(key) do
    value = get(key)
    _ensure(value, key)
  end

  defp _ensure(nil, key) do
    {:error, ~s/configuration key "#{to_string(key)}" is not defined/}
  end

  defp _ensure(_value, _key), do: :ok
end
