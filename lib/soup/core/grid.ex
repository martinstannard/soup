defmodule Soup.Grid do
  use GenServer

  @sides 4
  @countdown 60
  @letters "EEEEEEEEEEEETTTTTTTTTAAAAAAAAOOOOOOOIIIIIIINNNNNNNSSSSSSSHHHHHHRRRRRRDDDDLLLCCCUUUMMMWWWFFFGGYYPPBBVKJXQZ"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: Board)
  end

  def new(pid) do
    GenServer.call(pid, :new)
  end

  def grid(pid) do
    GenServer.call(pid, :grid)
  end

  def add_word(pid, word) do
    GenServer.call(pid, {:add_word, word})
  end

  def used?(pid, word) do
    GenServer.call(pid, {:used?, word})
  end

  def init(_) do
    Process.send_after(self(), :tick, 1000)

    {:ok,
     %{
       grid: generate(),
       time: @countdown,
       words: []
     }}
  end

  def handle_call(:new, _, _state) do
    state = %{grid: generate()}
    {:reply, state, state}
  end

  def handle_call(:grid, _, state) do
    {:reply, state.grid, state}
  end

  def handle_call({:add_word, word}, _, state) do
    new_state = %{state | words: [word] ++ state.words}
    IO.inspect(new_state, label: :add_word)
    {:reply, new_state, new_state}
  end

  def handle_call({:used?, word}, _, state) do
    {:reply, Enum.member?(state.words, word), state}
  end

  def handle_call(:words, _, state) do
    {:reply, state.words, state}
  end

  def handle_info(:tick, state) do
    new_state = do_tick(state)
    Process.send_after(self(), :tick, 1000)
    {:noreply, new_state}
  end

  def do_tick(%{time: 0}) do
    board = generate()
    SoupWeb.Endpoint.broadcast("soup", "new_board", %{board: board})
    SoupWeb.Endpoint.broadcast("soup", "words", %{words: []})

    %{
      grid: board,
      time: @countdown,
      words: []
    }
  end

  def do_tick(state) do
    SoupWeb.Endpoint.broadcast("soup", "tick", %{seconds: state.time - 1})
    %{state | time: state.time - 1}
  end

  def generate(sides \\ @sides) do
    for _x <- 1..sides do
      1..sides
      |> Enum.map(fn _ -> random_letter() end)
      |> to_string
      |> String.split("", trim: true)
    end
  end

  def random_letter do
    @letters
    |> String.split("", trim: true)
    |> Enum.random()
  end
end
