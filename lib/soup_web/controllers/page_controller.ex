defmodule SoupWeb.PageController do
  use SoupWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
