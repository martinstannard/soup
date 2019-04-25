defmodule SoupWeb.CountView do
  use Phoenix.LiveView

  alias Soup.Player
  alias Soup.PlayerServer

  def render(assigns) do
    ~L"""
    <h2>Time: <%= @seconds %></h2>
    <div class="">
      <%= Enum.map(@grid, fn(row) -> %>
        <div>
          <%= Enum.map(row, fn(c) -> %>
            <span class='letter' phx-click="letter" phx-value=<%= c%>><%= c %></span>
          <% end) %>
        </div>
      <% end) %>

      <div class='word'>
        <%= @word %>
      </div>
      <div>
        <button phx-click="submit">submit</button>
      </div>
      <div>
        <button phx-click="clear">clear</button>
      </div>
      <h2>Score: <%= @score %></h2>
      <div>
      <h2>Words</h2>
        <%= Enum.map(@words, fn(w) -> %>
          <div><%= w %></div>
        <% end) %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: SoupWeb.Endpoint.subscribe("soup")
    socket = assign(socket, :word, "")
    socket = assign(socket, :words, [])
    socket = assign(socket, :score, 0)
    socket = assign(socket, :seconds, 30)
    socket = assign(socket, :grid, GenServer.call(Board, :grid))
    socket = assign(socket, :pid, PlayerServer.find_or_create_player(socket.id))

    {:ok, socket}
  end

  def handle_event("letter", value, socket) do
    Player.add_letter(socket.assigns.pid, value)
    word = Player.word(socket.assigns.pid)
    {:noreply, assign(socket, :word, word)}
  end

  def handle_event("clear", _, socket) do
    Player.clear(socket.assigns.pid)
    {:noreply, assign(socket, :word, "")}
  end

  def handle_event("submit", _, socket) do
    handle_valid(valid?(socket), socket)
    socket = assign_state(socket)
    {:noreply, socket}
  end

  def handle_info(%{event: "new_board", payload: payload}, socket) do
    Player.clear(socket.assigns.pid)
    socket = assign(socket, :word, "")
    socket = assign(socket, :grid, payload.board)
    {:noreply, socket}
  end

  def handle_info(%{event: "tick", payload: payload}, socket) do
    socket = assign(socket, :seconds, payload.seconds)
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    IO.inspect(reason)
    PlayerServer.remove(socket.assigns.pid)
  end

  def assign_state(socket) do
    state = Player.state(socket.assigns.pid)
    socket = assign(socket, :word, state.word)
    socket = assign(socket, :words, state.words)
    socket = assign(socket, :score, state.score)
    socket
  end

  defp valid?(socket) do
    state = Player.state(socket.assigns.pid)

    GenServer.call(Dict, {:valid?, state.word})
    |> IO.inspect(label: :valid)
  end

  defp handle_valid(true, socket) do
    Player.submit(socket.assigns.pid)
    Player.clear(socket.assigns.pid)
  end

  defp handle_valid(_, socket) do
    Player.clear(socket.assigns.pid)
  end
end
