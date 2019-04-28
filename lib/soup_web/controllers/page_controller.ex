defmodule SoupWeb.PageController do
  use SoupWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def game(conn, params) do
    LiveView.Controller.live_render(conn, SoupWeb.GridLive, session: params)
  end
end
