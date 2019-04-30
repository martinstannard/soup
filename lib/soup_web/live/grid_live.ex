defmodule SoupWeb.GridLive do
  use Phoenix.LiveView

  alias Soup.{Player, PlayerServer}
  alias SoupWeb.GridView

  def render(assigns) do
    GridView.render("grid.html", assigns)
  end

  def mount(%{"user" => %{"name" => name}}, socket) do
    if connected?(socket), do: SoupWeb.Endpoint.subscribe("soup")
    socket = init_socket(socket, name)
    SoupWeb.Endpoint.broadcast("soup", "scores", %{scores: PlayerServer.scores()})

    {:ok, socket}
  end

  def handle_event("letter", value, socket) do
    Player.add_letter(socket.assigns.pid, value)
    {:noreply, assign(socket, :word, Player.word(socket.assigns.pid))}
  end

  def handle_event("clear", _, socket) do
    Player.clear(socket.assigns.pid)
    {:noreply, assign(socket, :word, "")}
  end

  def handle_event("submit", _, socket) do
    socket =
      socket
      |> valid?
      |> handle_valid(socket)

    {:noreply, assign_state(socket)}
  end

  def handle_info(%{event: "new_board", payload: payload}, socket) do
    Player.clear(socket.assigns.pid)

    socket =
      socket
      |> assign(:word, "")
      |> assign(:grid, payload.board)

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

  def handle_info(%{event: "words", payload: payload}, socket) do
    socket = assign(socket, :words, payload.words)
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    PlayerServer.remove(socket.assigns.pid)
    SoupWeb.Endpoint.broadcast("soup", "scores", %{scores: PlayerServer.scores()})
  end

  defp assign_state(socket) do
    state = Player.state(socket.assigns.pid)
    socket = assign(socket, :word, state.word)
    socket = assign(socket, :score, state.score)
    SoupWeb.Endpoint.broadcast("soup", "scores", %{scores: PlayerServer.scores()})
    SoupWeb.Endpoint.broadcast("soup", "words", %{words: GenServer.call(Board, :words)})
    socket
  end

  defp valid?(socket) do
    word = Player.state(socket.assigns.pid).word

    with true <- String.length(word) > 3,
         false <- GenServer.call(Board, {:used?, word}),
         true <- GenServer.call(Board, {:valid_letters?, word}),
         true <- GenServer.call(Dict, {:valid?, word}) do
      true
    else
      _ -> false
    end
  end

  defp handle_valid(true, socket) do
    GenServer.call(Board, {:add_word, Player.word(socket.assigns.pid)})
    Player.submit(socket.assigns.pid)
    Player.clear(socket.assigns.pid)
    socket
  end

  defp handle_valid(_, socket) do
    Player.clear(socket.assigns.pid)
    socket = put_flash(socket, :info, "Invalid word")

    socket
  end

  defp init_socket(socket, name) do
    pid = PlayerServer.find_or_create_player(socket.id, name)

    socket
    |> assign(:word, "")
    |> assign(:words, [])
    |> assign(:name, Player.name(pid))
    |> assign(:seconds, 60)
    |> assign(:scores, PlayerServer.scores())
    |> assign(:grid, GenServer.call(Board, :grid))
    |> assign(:pid, pid)
  end
end
