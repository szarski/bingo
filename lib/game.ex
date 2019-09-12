defmodule Game do
  require GenServer
  require Logger

  @players_count 5

  def start_link(game_number) do
    GenServer.start_link(__MODULE__, game_number, name: :"Game_#{game_number}")
  end

  def init(game_number) do
    players = 1..@players_count |> Enum.map(&create_player(game_number, &1))

    {:ok, %{players: players, game_number: game_number, numbers: []}}
  end

  def handle_call(
        :play,
        _from,
        %{players: players, numbers: numbers} = state
      ) do
    number = Enum.random(1..100)

    new_state =
      state
      |> Map.put(:players, players |> Enum.filter(&player_still_playing?(&1, number)))
      |> Map.put(:numbers, numbers |> Enum.concat([number]))

    case new_state do
      %{players: []} ->
        {:stop, :normal, true, new_state}

      _ ->
        {:reply, false, new_state}
    end
  end

  defp create_player(game_number, player_number) do
    {:ok, pid} = Player.start_link(game_number, player_number)
    pid
  end

  defp player_still_playing?(player, number) do
    finished = GenServer.call(player, {:number, number})
    !finished
  end

  def handle_call(
        :to_s,
        _from,
        %{players: players, game_number: game_number, numbers: numbers} = state
      ) do
    player_information =
      players
      |> Enum.map(fn player -> GenServer.call(player, :to_s) end)
      |> Enum.chunk_every(3)
      |> Enum.map(fn elements ->
        0..7
        |> Enum.map(fn row_number ->
          elements
          |> Enum.map(fn element ->
            element |> String.split("\n") |> Enum.at(row_number) |> String.pad_trailing(25)
          end)
          |> Enum.join("  ")
        end)
        |> Enum.join("\n")
      end)
      |> Enum.join("\n\n")

    text =
      "============== Game #{game_number} ==============\n\n" <>
        "Numbers: #{numbers |> Enum.join(",")}\n" <>
        "\n" <> player_information <> "\n-----------------------------------------------\n\n"

    {:reply, text, state}
  end
end
