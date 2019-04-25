defmodule Soup.Grid do
  use GenServer

  @sides 5

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

  def init(_) do
    {:ok,
     %{
       grid: generate()
     }}
  end

  def handle_call(:new, _, _state) do
    state = %{grid: generate()}
    {:reply, state, state}
  end

  def handle_call(:grid, _, state) do
    {:reply, state.grid, state}
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
