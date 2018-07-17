defmodule BatchElixir.Serialisation do
  @moduledoc """
  Provide some helpers
  """

  @doc """
  Convert a structure to a map recursivly
  """
  def structure_to_map(%{__struct__: _} = structure) do
    structure
    |> Map.from_struct()
    |> Enum.map(fn
      {key, %{__struct__: _} = value} -> {key, structure_to_map(value)}
      other when is_list(other) -> Enum.map(other, &structure_to_map/1)
      other -> other
    end)
    |> Enum.into(%{})
  end

  def structure_to_map(value), do: value

  @doc """
  Compact a map by removing keys that have nil as value
  """
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
