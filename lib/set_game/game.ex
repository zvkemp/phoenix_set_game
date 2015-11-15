
defmodule SetGame.Game do
  defstruct displayed: [], deck: [], players: %{}, over: false

  alias SetGame.Game, as: G
  alias SetGame.Detector, as: D

  @min_deal 12

  def new() do
    :random.seed(:erlang.now) # TODO: where does this go?
    %G{ deck: SetGame.shuffled_deck } |> show_cards_until(@min_deal) |> IO.inspect # |> show_until_set_displayed
  end

  # returns { true|false, game }, (false if set was not valid)
  def find_set!(%G{ displayed: d } = game, a, b, c, name \\ "unknown") do
    # validations:
    # x. all three unique (SET)
    # 2. is set
    # 3. cards are currently displayed
    import SetGame.Set

    valid_set = is_set?(a, b, c) && Enum.all?([a, b, c], &Enum.member?(d, &1))

    game = cond do
      valid_set -> %G{ game | displayed: d -- [a, b, c] } |> update_score(name) |> show_cards_until(@min_deal)
      :else     -> game
    end

    game = case over?(game) do
      true -> %G{ game | over: true }
      _    -> game
    end

    { valid_set, game }
  end

  def over?(%G{ deck: [] } = game) do
    !set_displayed?(game)
  end
  def over?(_), do: false

  # at least one set displayed?
  def set_displayed?(%G{ displayed: d }) do
    D.new(d) |> D.includes_set?
  end

  # necessary?
  defp show_until_set_displayed(%G{} = game) do
    cond do
      set_displayed?(game) -> game
      true -> show_until_set_displayed(game |> show_3)
    end
  end

  defp update_score(%G{ players: p } = game, name) do
    %G{ game | players: Map.update(p, name, 1, &(&1 + 1)) }
  end

  def show_3(%G{ deck: [] } = game), do: game
  def show_3(%G{ displayed: d, deck: r } = game) do
    { add, r } = Enum.split(r, 3)
    %G{ game | displayed: d ++ add, deck: r }
  end

  def show_cards(%G{} = game, n_cards) do
    (1..n_cards) |> Enum.reduce(game, &show_card/2)
  end

  def show_cards_until(%G{ displayed: d } = game, n_cards) do
    diff = n_cards - Enum.count(d)
    cond do
      diff > 0 -> show_cards(game, diff)
      true -> game
    end
  end

  defp show_card(_, %G{} = game), do: show_card(game) # for looping in reduce

  defp show_card(%G{ displayed: d, deck: [c|r] } = game) do
    %G{ game | displayed: [c|d], deck: r }
  end

  defp show_card(%G{ deck: [] } = game), do: game

  defp all_unique?(a, b, c) do
    (Enum.uniq([a, b, c]) |> Enum.count) == 3
  end
end
