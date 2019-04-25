defmodule SoupWeb.PageController do
  use SoupWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _) do
    LiveView.Controller.live_render(conn, SoupWeb.GridLive, session: %{})
  end
end
