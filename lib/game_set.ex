defmodule GameSet do
  require GenServer
  require Logger

  @simultanous_games 2
  @max_games 10

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :GameSet)
  end

  def init(_) do
    state = start_games(%{game_counter: 0, games: []})

    {:ok, state}
  end

  def handle_info(:game_finished, %{games: games} = state) do
    Logger.warn("Game finishing.")

    new_state =
      start_games(
        state
        |> Map.put(:games, games |> Enum.filter(fn game -> Process.alive?(game) end))
      )

    case Enum.empty?(new_state |> Map.get(:games)) do
      false ->
        {:noreply, new_state}

      true ->
        Logger.error("All games finished!")
        {:stop, :normal, new_state}
    end
  end

  defp start_games(%{games: games} = state) when length(games) >= @simultanous_games do
    state
  end

  defp start_games(%{game_counter: counter} = state) when counter >= @max_games do
    state
  end

  defp start_games(%{games: games, game_counter: counter} = state) do
    missing = @simultanous_games - length(games)

    games =
      1..missing
      |> Enum.map(fn i ->
        {:ok, pid} = Game.start_link(counter + i)
        pid
      end)
      |> Enum.concat(games)

    state |> Map.merge(%{games: games, game_counter: counter + missing})
  end
end
