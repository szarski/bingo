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

    loop()

    {:ok, state}
  end

  def handle_info(:loop, %{} = state) do
    case start_games(state) do
      %{games: []} = new_state ->
        Logger.error("All games finished!")
        {:stop, :normal, new_state}

      %{games: games} = new_state ->
        IEx.Helpers.clear()

        games
        |> Enum.sort()
        |> Enum.each(fn game ->
          Logger.info(GenServer.call(game, :to_s))
          GenServer.call(game, :play)
        end)

        loop()
        {:noreply, new_state}
    end
  end

  defp loop do
    Process.send_after(self(), :loop, 50)
  end

  defp start_games(%{games: games, game_counter: counter} = state) do
    games_in_progress = games |> Enum.filter(fn game -> Process.alive?(game) end)

    if length(games_in_progress) < @simultanous_games && counter < @max_games do
      start_games(
        state
        |> Map.merge(%{
          games: games_in_progress |> Enum.concat([start_game(counter + 1)]),
          game_counter: counter + 1
        })
      )
    else
      state |> Map.put(:games, games_in_progress)
    end
  end

  defp start_game(number) do
    {:ok, pid} = Game.start_link(number)
    pid
  end
end
