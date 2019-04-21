defmodule SoupWeb.CountView do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="">
      <div>
        <%= @count %>
      </div>
      <div>
        <button phx-click="inc">Inc</button>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do

    {:ok, assign(socket, count: 0)}

  end
end
