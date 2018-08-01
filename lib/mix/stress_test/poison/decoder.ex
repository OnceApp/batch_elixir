defmodule StressTest.Poison.Decoder do
  alias Poison.Decoder

  defimpl Decoder, for: BitString do
    def decode(data, _options) do
      data
      |> String.starts_with?("Elixir.")
      |> _value_is_atom?(data)
    end

    defp _value_is_atom?(true, value), do: String.to_atom(value)
    defp _value_is_atom?(false, value), do: value
  end

  defimpl Decoder, for: Map do
    def decode(data, options) do
      data
      |> Enum.map(fn {key, value} ->
        {key, Decoder.decode(value, options)}
      end)
      |> Enum.into(%{})
    end
  end

  defimpl Decoder, for: List do
    def decode(data, options) do
      data |> _decode(options)
    end

    defp _decode([key | [value | []]], options) when is_binary(key) do
      {String.to_atom(key), Decoder.decode(value, options)}
    end

    defp _decode(list, options) do
      list
      |> Enum.map(&_decode(&1, options))
    end
  end
end
