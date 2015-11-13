
defmodule SetGame.Set do
  def is_set?([a, b, c]), do: is_set?(a, b, c)
  def is_set?(a, b, _) when a == b, do: false
  def is_set?(a, _, b) when a == b, do: false
  def is_set?(_, a, b) when a == b, do: false
  def is_set?(a, b, c) when is_integer(a) and is_integer(b) and is_integer(c) do
    # For each attribute, the sum of the base-3 digits must be
    # 0, 3, or 6. Sums of 1, 2, 4, or 5 are invalid sets.
    # SETS:
    # 0, 1, 2 = 3
    # 0, 0, 0 = 0
    # 1, 1, 1 = 3
    # 2, 2, 2 = 6
    # NOT:
    # 0, 1, 0 = 1
    # 2, 2, 0 = 4
    # 2, 2, 1 = 5
    # 2, 1, 1 = 4
    # 0, 1, 1 = 2
    # 0, 2, 0 = 2

    Enum.map([a, b, c], &SetGame.Card.bits/1)
    |> List.zip
    |> Enum.all?(fn { a, b, c } ->
       case a + b + c do
         0 -> true
         3 -> true
         6 -> true
         _ -> false
       end
    end)
  end
end
