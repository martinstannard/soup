defmodule SoupWeb.PageController do
  use SoupWeb, :controller

  alias Phoenix.LiveView

  # def index(conn, _params) do
  #   render(conn, "index.html")
  # end
  def index(conn, _) do
    LiveView.Controller.live_render(conn, SoupWeb.CountView, session: %{})
  end
end
