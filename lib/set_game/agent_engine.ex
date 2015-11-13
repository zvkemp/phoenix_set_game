defmodule SetGame.AgentEngine do
  def start_game(room_name) do
    SetGame.Registry.create_and_lookup(room_name)
  end

  def start_game do
    { :ok, pid } = Agent.start_link(fn -> SetGame.Game.new end)
    pid
  end

  # def register_player(pid) do
  #   game = Agent.get(pid, &(&1))
  #   n = (Enum.count(game.players)) + 1
  #   player_id = "player #{n}"
  #   Agent.update(pid, fn (g) ->
  #     %SetGame.Game{ g | players: Map.put(g.players, player_id, 0) }
  #   end)

  #   player_id
  # end

  def hint(pid) do
    Agent.get(pid, &(SetGame.Detector.hint(&1)))
  end

  def display_more(pid) do
    Agent.update(pid, &SetGame.Game.show_3/1)
  end

  def game_state(pid) do
    %SetGame.Game{ displayed: d, players: p } = Agent.get(pid, &(&1))
    IO.inspect [:players, p]
    %{
      players: p |> Enum.map(fn { k, v } -> %{ name: k, score: v } end),
      cards: d |> Enum.map(&SetGame.Card.decode_map/1)
    }
  end

  def find_set!(pid, [a, b, c], name \\ "unknown") do
    IO.inspect ["find_set", name, pid, [a, b, c]]
    Agent.update(pid, &(SetGame.Game.find_set!(&1, a, b, c, name)))
  end
end
