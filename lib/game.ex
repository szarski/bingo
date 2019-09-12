defmodule Game do
  require GenServer
  require Logger

  @players_count 5

  def start_link(game_number) do
    GenServer.start_link(__MODULE__, game_number, name: :"Game_#{game_number}")
  end

  def init(game_number) do
    Logger.info("Game #{game_number}: starting!")

    players =
      1..@players_count
      |> Enum.map(fn player_number ->
        {:ok, pid} = Player.start_link(game_number, player_number)
        pid
      end)

    :timer.sleep(4000)

    loop()
    {:ok, %{players: players, game_number: game_number}}
  end

  def handle_info(:loop, %{players: players, game_number: game_number} = state) do
    number = Enum.random(1..100)

    Logger.info("Game #{game_number}: The next number is #{number}")

    players_left =
      players
      |> Enum.filter(fn player ->
        finished = GenServer.call(player, {:number, number})
        !finished
      end)

    if Enum.count(players_left) < Enum.count(players) do
      Logger.info("Game #{game_number}: Players left: #{players_left |> Enum.count()}")
      :timer.sleep(2000)
    end

    case players_left do
      [] ->
        Process.send_after(:GameSet, :game_finished, 50)
        {:stop, :normal, state |> Map.put(:players, players_left)}

      _ ->
        loop()
        {:noreply, state |> Map.put(:players, players_left)}
    end
  end

  defp loop do
    Process.send_after(self(), :loop, 50)
  end
end
