defmodule Player do
  require GenServer
  require Logger

  def start_link(player_number) do
    GenServer.start_link(__MODULE__, player_number, name: :"Player_#{player_number}")
  end

  def init(player_number) do
    board = Board.generate()
    Logger.info("Player #{player_number} joined with board:#{board |> Board.inspect()}")
    {:ok, %{player_number: player_number, numbers: [], board: board}}
  end
end
