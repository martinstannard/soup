defmodule Soup.Counter do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: Counter)
  end

  def inc(pid) do
    GenServer.call(pid, :inc)
  end

  def count(pid) do
    GenServer.call(pid, :count)
  end

  def init(_) do
    {:ok, 0}
  end

  def handle_call(:inc, _, state) do
    {:reply, state + 2, state + 2}
  end

  def handle_call(:count, _, state) do
    {:reply, state, state}
  end
end
