
defmodule SetGame.Detector do
  defstruct cards: [], count: 0, index: %{}

  alias SetGame.Detector, as: D

  def new(cards) do
    %D{
      cards: cards,
      index: Stream.zip(idx_stream, cards) |> Enum.into(%{}),
      count: Enum.count(cards)
    }
  end

  def includes_set?(%D{} = d) do
    Enum.any?(permutations(d), fn ({ a, b, c } = t) ->
      SetGame.Set.is_set?(cards(d, t))
    end)
  end

  def hint(%SetGame.Game{ displayed: d } = game) do
    hint(SetGame.Detector.new(d))
  end

  def hint(%D{} = d) do
    s = Enum.find(permutations(d), fn ({ a, b, c } = t) ->
      SetGame.Set.is_set?(cards(d, t))
    end)

    case s do
      nil -> nil
      _ -> cards(d, s)
    end
  end

  defp permutations(%D{count: count}) do
    for x <- (1..(count-2)),
        y <- ((x+1)..(count-1)),
        z <- ((y+1)..count) do
      { x, y, z }
    end
  end

  defp cards(d, { a, b, c }) do
    [ d.index[a], d.index[b], d.index[c] ]
  end

  defp idx_stream, do: Stream.iterate(1, &(&1 + 1))
end
