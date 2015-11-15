defmodule SetGame.GameChannelTest do
  use SetGame.ChannelCase

  alias SetGame.Registry
  alias SetGame.GameChannel
  alias SetGame.AgentEngine

  setup do
    {:ok, _, socket} = socket() |> subscribe_and_join(GameChannel, "games:new_game")
    {:ok, socket: socket}
  end

  test "the channel registers a game", %{ socket: socket } do
    { :ok, pid } = Registry.lookup(socket.topic)
    assert %SetGame.Game{} = Agent.get(pid, &(&1))
  end

  test "the channel pushes game state on join", %{ socket: socket } do
    assert_push "game_state", %{ cards: cards, over: false }
  end

  defp game_state(socket) do
    { :ok, pid } = Registry.lookup(socket.topic)
    Agent.get(pid, &(&1))
  end

  test "show_more", %{ socket: socket } do
    push socket, "show_more", {}
    assert (game_state(socket).displayed |> Enum.count) == 12
    assert_broadcast "game_state", %{ cards: cards, over: false }
    assert (game_state(socket).displayed |> Enum.count) == 15
  end

  test "new_game", %{ socket: socket } do
    original_game = game_state(socket)
    assert original_game == game_state(socket) # idempotency
    push socket, "new_game", {}
    assert_broadcast "game_state", %{ cards: cards, over: false }
    refute original_game == game_state(socket)
  end

  test "find_set with correct set", %{ socket: socket } do
    hint = SetGame.Detector.hint(game_state(socket))
    push socket, "find_set", %{ "name" => "zk", "set" => hint }
    assert_broadcast "game_state", %{ players: [%{ name: "zk", score: 1 }] }
  end

  test "find_set with incorrect set", %{ socket: socket } do
    push socket, "find_set", %{ "name" => "zk", "set" => [0, 1, 3] }
    assert_broadcast "game_state", %{ players: [] }
  end
end
