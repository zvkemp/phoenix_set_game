defmodule SetGame.PageController do
  use SetGame.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
