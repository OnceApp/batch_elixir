defmodule BatchElixir.Utils do
  def structure_to_map(%{__struct__: _} = structure) do
    structure
    |> Map.from_struct()
    |> Enum.map(fn
      {key, %{__struct__: _} = value} -> {key, structure_to_map(value)}
      other -> other
    end)
    |> Enum.into(%{})
  end

  def structure_to_map(value), do: value

  def compact_map(map) do
    map
    |> Enum.reject(fn {_, v} -> v == nil end)
    |> Enum.map(fn
      {key, %{} = value} -> {key, compact_map(value)}
      other -> other
    end)
    |> Enum.into(%{})
  end
end
