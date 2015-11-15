defmodule SetGame.GameChannel do
  use Phoenix.Channel

  alias SetGame.AgentEngine, as: A


  @default_inteval 10000

  def join("games:new_game" = room, _message, socket) do
    { :ok, pid } = A.start_game(room)
    send(self, :after_join)
    { :ok, socket }
  end

  def handle_info(:after_join, socket) do
    push socket, "game_state", game_state(socket)
    { :noreply, socket }
  end

  def handle_info(:show_more_if_necessary, socket) do
    update_and_broadcast_game!(socket, fn (p) ->
      A.display_more(p, :if_necessary)
    end, nil)
  end

  # reset_timers
  def handle_in("show_more", _msg, socket) do
    update_and_broadcast_game!(socket, &A.display_more/1)
  end

  def handle_in("new_game", _msg, socket) do
    update_and_broadcast_game!(socket, &A.replace_game/1)
  end

  # on find set, reset_timers
  def handle_in("find_set", %{"name" => name, "set" => [a, b, c] }, socket) do
    update_and_broadcast_game!(socket, fn p -> A.find_set!(p, [a, b, c], name) end)
  end

  def handle_in("hint", msg, socket) do
    n = Map.get(msg, "n", 2)
    push socket, "hint", %{ hint: (A.hint(socket |> game_pid) || []) |> Enum.take(n) }
    { :noreply, socket }
  end

  defp game_state(_lookup, show_more_interval \\ @default_inteval)
  defp game_state(%Phoenix.Socket{} = s, show_more_interval) do
    game_state(s |> game_pid, show_more_interval)
  end
  defp game_state(pid, show_more_interval) when is_pid(pid) do
    show_more_interval && :timer.send_after(show_more_interval, :show_more_if_necessary)
    A.game_state(pid)
  end

  defp game_pid(%Phoenix.Socket{ topic: name }) do
    { :ok, pid } = SetGame.Registry.create_and_lookup(name)
    pid
  end

  defp update_game(socket, callback, show_more_interval \\ @default_inteval) do
    callback = callback || fn (_) -> end
    pid = game_pid(socket)
    callback.(pid)
    game_state(pid, show_more_interval)
  end

  defp update_and_broadcast_game!(socket, callback, show_more_interval \\ @default_inteval) do
    broadcast! socket, "game_state", update_game(socket, callback, show_more_interval)
    {:noreply, socket }
  end
end
