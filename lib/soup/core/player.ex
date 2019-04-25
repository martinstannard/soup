defmodule Soup.Player do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, [])
  end

  def add_letter(pid, letter) do
    GenServer.call(pid, {:add_letter, letter})
  end

  def word(pid) do
    GenServer.call(pid, :word)
  end

  def submit(pid) do
    GenServer.call(pid, :submit)
  end

  def clear(pid) do
    GenServer.call(pid, :clear)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def id(pid) do
    GenServer.call(pid, :id)
  end

  def init(id) do
    {:ok,
     %{
       id: id,
       score: 0,
       word: "",
       words: []
     }}
  end

  def handle_call({:add_letter, letter}, _, state) do
    new_state = %{state | word: state.word <> letter}
    {:reply, new_state, new_state}
  end

  def handle_call(:word, _, state) do
    {:reply, state.word, state}
  end

  def handle_call(:clear, _, state) do
    new_state = %{state | word: ""}
    {:reply, new_state, new_state}
  end

  def handle_call(:submit, _, state) do
    new_state = %{
      state
      | score: state.score + String.length(state.word),
        words: [state.word] ++ state.words,
        word: ""
    }

    {:reply, new_state, new_state}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  def handle_call(:id, _, state) do
    {:reply, state.id, state}
  end
end
