defmodule Game do
  require GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: CurrentGame)
  end

  def init(_) do
    Logger.info("Game starting!")

    players =
      1..15
      |> Enum.map(fn player_number ->
        {:ok, pid} = Player.start_link(player_number)
        pid
      end)

    {:ok, %{players: players}}
  end
end
