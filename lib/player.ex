defmodule Player do
  require GenServer
  require Logger

  def start_link(game_number, player_number) do
    GenServer.start_link(__MODULE__, player_number,
      name: :"Player_#{game_number}_#{player_number}"
    )
  end

  def init(player_number) do
    {:ok, %{player_number: player_number, numbers: [], board: Board.generate()}}
  end

  def handle_call(
        {:number, number},
        _from,
        %{numbers: old_numbers, board: board} = old_state
      ) do
    numbers = old_numbers |> Enum.concat([number])
    state = old_state |> Map.put(:numbers, numbers)

    case board |> Board.bingo?(numbers) do
      true ->
        {:stop, :normal, true, state}

      false ->
        {:reply, false, state}
    end
  end

  def handle_call(:to_s, _from, %{player_number: player_number, board: board} = state) do
    {:reply, "Player #{player_number}\n#{board |> Board.to_s()}", state}
  end
end
