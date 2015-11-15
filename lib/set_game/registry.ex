defmodule SetGame.Registry do
  use GenServer

  @default_server Games

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(name, server \\ @default_server) do
    GenServer.call(server, {:lookup, name})
  end

  def create(name, server \\ @default_server) do
    GenServer.cast(server, {:create, name})
  end

  def create_and_lookup(name, server \\ @default_server) do
    create(name, server)
    lookup(name, server)
  end

  def init(:ok) do
    { :ok, HashDict.new }
  end

  def handle_call({ :lookup, name }, _from, names) do
    {:reply, HashDict.fetch(names, name), names}
  end

  def handle_call({ :get_all }, _from, names) do
    { :reply, names, names }
  end

  def handle_cast({ :create, name }, names) do
    if HashDict.has_key?(names, name) do
      { :noreply, names }
    else
      game = SetGame.AgentEngine.start_game
      { :noreply, HashDict.put(names, name, game) }
    end
  end
end
