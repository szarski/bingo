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

  def handle_call(
        {:number, number},
        _from,
        %{player_number: player_number, numbers: old_numbers, board: board} = old_state
      ) do
    numbers = old_numbers |> Enum.concat([number])
    state = old_state |> Map.put(:numbers, numbers)

    case board |> Board.bingo?(numbers) do
      true ->
        Logger.info("Player #{player_number}: Bingo!")
        {:stop, :normal, true, state}

      false ->
        {:reply, false, state}
    end
  end
end
