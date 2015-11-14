defmodule SetGame.GameChannel do
  use Phoenix.Channel
  # require IEx

  alias SetGame.Registry, as: R
  alias SetGame.AgentEngine, as: A

  def join("games:new_game" = room, _message, socket) do
    { :ok, pid } = A.start_game(room)
    # player_id = A.register_player(pid)
    socket = socket |> Phoenix.Socket.assign(:pid, pid)

    send(self, :after_join)
    { :ok, socket }
  end

  def handle_info(:after_join, socket) do
    pid = socket.assigns[:pid]
    push socket, "game_state", game_state(pid, socket)
    { :noreply, socket }
  end

  def handle_in("show_more", _msg, socket) do
    pid = socket.assigns[:pid]
    SetGame.AgentEngine.display_more(pid)
    broadcast! socket, "game_state", game_state(pid, socket)
    {:noreply, socket }
  end

  def handle_in("new_game", _msg, socket) do
    pid = socket.assigns[:pid]
    SetGame.AgentEngine.replace_game(pid)
    broadcast! socket, "game_state", game_state(pid, socket)
    { :noreply, socket }
  end

  def handle_in("find_set", %{"name" => name, "set" => [a, b, c] }, socket) do
    pid = socket.assigns[:pid]
    SetGame.AgentEngine.find_set!(pid, [a, b, c], name)
    broadcast! socket, "game_state", game_state(pid, socket)
    {:noreply, socket }
  end

  defp game_state(pid, socket) do
    A.game_state(pid)
  end
end
