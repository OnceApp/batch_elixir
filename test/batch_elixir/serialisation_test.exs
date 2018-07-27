defmodule BatchElixir.SerialisationTest do
  alias BatchElixir.Serialisation

  defmodule Submodule do
    defstruct [:answer]
  end

  defstruct [:sub_module, :list, :map, :int, :other]
  use ExUnit.Case

  test "Converting a structure to a map" do
    sub_module = %Submodule{answer: 42}
    list = [1, 1, 2, 3, sub_module]
    map = %{"best_movie_ever" => "Gattaca"}

    structure = %__MODULE__{
      sub_module: sub_module,
      list: list,
      map: map,
      int: 42,
      other: nil
    }

    assert %{
             sub_module: %{answer: 42},
             list: [1, 1, 2, 3, %{answer: 42}],
             map: ^map,
             int: 42,
             other: nil
           } = Serialisation.structure_to_map(structure)
  end

  test "Removing nil values from a map" do
    sub_module = %{answer: 42}
    list = [1, 1, 2, 3, sub_module]
    map = %{"best_movie_ever" => "Gattaca", "bad_points_elixir" => nil}

    structure = %{
      sub_module: sub_module,
      list: list,
      map: map,
      int: 42,
      other: nil
    }

    assert %{
             sub_module: %{answer: 42},
             list: [1, 1, 2, 3, %{answer: 42}],
             map: %{"best_movie_ever" => "Gattaca"},
             int: 42
           } = Serialisation.compact_map(structure)
  end
end
