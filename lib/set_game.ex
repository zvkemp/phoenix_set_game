defmodule SetGame do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(SetGame.Endpoint, []),
      # Start the Ecto repository
      worker(SetGame.Repo, []),
      # Here you could define other workers and supervisors as children
      worker(SetGame.Registry, [[name: Games]])
      # NOTE: Providing name: Games allows lookups using Games in
      # place of a PID:
      # SetGame.Registry.lookup(Game, "new")
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SetGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SetGame.Endpoint.config_change(changed, removed)
    :ok
  end


  # TODO: Move to Deck module ?
  @colors ~w(blue red green)a
  @shapes ~w(oval diamond squiggle)a
  @fills  ~w(solid open striped)a
  @counts [1, 2, 3]

  def shuffled_deck do
    :random.seed(:erlang.now)
    standard_deck |> Enum.shuffle
  end

  def standard_deck do
    (0..80)
  end

  def colors, do: @colors
  def shapes, do: @shapes
  def fills,  do: @fills
  def counts, do: @counts
end
