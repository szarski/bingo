defmodule Game do
  require GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :CurrentGame)
  end

  def init(_) do
    Logger.info("Game starting!")

    players =
      1..15
      |> Enum.map(fn player_number ->
        {:ok, pid} = Player.start_link(player_number)
        pid
      end)

    loop()
    {:ok, %{players: players}}
  end

  def handle_info(:loop, %{players: players} = state) do
    number = Enum.random(1..100)

    Logger.info("The next number is #{number}")

    players_left =
      players
      |> Enum.filter(fn player ->
        finished = GenServer.call(player, {:number, number})
        !finished
      end)

    if Enum.count(players_left) < Enum.count(players) do
      Logger.info("Players left: #{players_left |> Enum.count()}")
      :timer.sleep(2000)
    end

    case Enum.empty?(players_left) do
      false ->
        loop()
        {:noreply, state |> Map.put(:players, players_left)}

      true ->
        {:stop, :normal, state |> Map.put(:players, players_left)}
    end
  end

  defp loop do
    Process.send_after(self(), :loop, 50)
  end
end
