defmodule Soup.Dict do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: Dict)
  end

  def valid?(word) do
    GenServer.call(Dict, {:valid?, word})
  end

  def init(_) do
    {:ok, %{words: load_dictionary()}}
  end

  def handle_call({:valid?, word}, _, state) do
    valid = Enum.member?(state.words, String.downcase(word))
    {:reply, valid, state}
  end

  defp load_dictionary do
    {:ok, words} = File.read("sowpods.txt")
    format_words(words)
  end

  defp format_words(words) do
    words
    |> String.downcase()
    |> String.split("\n")
  end
end
