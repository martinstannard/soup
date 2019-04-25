defmodule SoupWeb.GridLive do
  use Phoenix.LiveView

  alias Soup.Player
  alias Soup.PlayerServer
  alias SoupWeb.GridView

  def render(assigns) do
    GridView.render("grid.html", assigns)
  end

  def mount(_session, socket) do
    IO.inspect("Mounting #{socket.id}")
    if connected?(socket), do: SoupWeb.Endpoint.subscribe("soup")
    socket = init_socket(socket)
    SoupWeb.Endpoint.broadcast("soup", "scores", %{scores: PlayerServer.scores()})

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

  def handle_info(%{event: "scores", payload: payload}, socket) do
    socket = assign(socket, :scores, payload.scores)
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    IO.inspect(reason, label: :terminate)
    PlayerServer.remove(socket.assigns.pid)
    SoupWeb.Endpoint.broadcast("soup", "scores", %{scores: PlayerServer.scores()})
  end

  def assign_state(socket) do
    state = Player.state(socket.assigns.pid)
    socket = assign(socket, :word, state.word)
    socket = assign(socket, :words, state.words)
    socket = assign(socket, :score, state.score)
    SoupWeb.Endpoint.broadcast("soup", "scores", %{scores: PlayerServer.scores()})
    socket
  end

  defp valid?(socket) do
    state = Player.state(socket.assigns.pid)

    GenServer.call(Dict, {:valid?, state.word})
  end

  defp handle_valid(true, socket) do
    Player.submit(socket.assigns.pid)
    Player.clear(socket.assigns.pid)
  end

  defp handle_valid(_, socket) do
    Player.clear(socket.assigns.pid)
  end

  defp init_socket(socket) do
    socket = assign(socket, :word, "")
    socket = assign(socket, :words, [])
    socket = assign(socket, :score, 0)
    socket = assign(socket, :seconds, 30)
    socket = assign(socket, :scores, [])
    socket = assign(socket, :grid, GenServer.call(Board, :grid))
    socket = assign(socket, :pid, PlayerServer.find_or_create_player(socket.id))
    socket
  end
end
