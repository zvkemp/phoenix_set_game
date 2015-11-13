defmodule SetGame.Card do
  @attrs ~w(color shape fill count)a
  defstruct @attrs

  alias SetGame.Card, as: C

  def encode([color, shape, fill, count]) do
    import SetGame
    [
      encode_attr(color, colors),
      encode_attr(shape, shapes),
      encode_attr(fill, fills),
      encode_attr(count, counts)
    ] |> Enum.join("") |> String.to_integer(3)
  end

  defp encode_attr(attr, attrs) do
    Enum.find_index(attrs, &(&1 == attr))
  end

  defp decode_attr(index, attrs) do
    Enum.at(attrs, index)
  end

  def decode(int) when int > 80 do
    raise RuntimeError, "Out of range"
  end

  def decode(int) when int < 0 do
    raise RuntimeError, "Out of range"
  end

  def decode(int) do
    import SetGame
    [c, s, f, n] = int |> bits

    [
      decode_attr(c, colors),
      decode_attr(s, shapes),
      decode_attr(f, fills),
      decode_attr(n, counts)
    ]
  end

  def decode_map(int) do
    Enum.zip(~w(color shape fill count)a, decode(int)) |> Enum.into(%{}) |> Map.put(:id, int)
  end

  def bits(int) do
    import String
    int
    |> Integer.to_string(3)
    |> rjust(4, ?0)
    |> split("", trim: true)
    |> Enum.map(&to_integer/1)
  end
end
