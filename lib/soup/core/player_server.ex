defmodule Soup.PlayerServer do
  @moduledoc """
  A supervisor for players
  """

  use DynamicSupervisor
  alias Soup.Player

  def find_or_create_player(player_id) do
    player_id
    |> find_player
    |> add_player(player_id)
  end

  defp add_player(nil, player_id) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        __MODULE__,
        %{
          id: Player,
          start: {Player, :start_link, [player_id]}
        }
      )

    pid
  end

  defp add_player(pid, _), do: pid

  defp find_player(id) do
    Enum.find(players(), fn child ->
      Player.id(child) == id
    end)
  end

  def players do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.map(fn {_, child, _, _} -> child end)
  end

  def remove(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def scores do
    players()
    |> Enum.map(fn pid ->
      "#{inspect(pid)} #{Player.score(pid)}"
    end)
  end

  ###
  # Supervisor API
  ###

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
