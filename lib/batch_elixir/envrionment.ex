defmodule BatchElixir.Environment do
  def get(key), do: Application.get_env(:batch_elixir, key)
  def get!(key), do: get(key) |> _get(key)

  defp _get(nil, key) do
    raise ArgumentError,
      message: ~s/configuration key "#{to_string(key)}" is not defined/
  end

  defp _get(value, _key), do: value
end
