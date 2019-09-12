defmodule Game do
  require GenServer
  require Logger

  @players_count 5

  def start_link(game_number) do
    GenServer.start_link(__MODULE__, game_number, name: :"Game_#{game_number}")
  end

  def init(game_number) do
    players =
      1..@players_count
      |> Enum.map(fn player_number ->
        {:ok, pid} = Player.start_link(game_number, player_number)
        pid
      end)

    {:ok, %{players: players, game_number: game_number, numbers: []}}
  end

  def handle_call(
        :play,
        _from,
        %{players: players, game_number: game_number, numbers: numbers} = state
      ) do
    number = Enum.random(1..100)

    players_left =
      players
      |> Enum.filter(fn player ->
        finished = GenServer.call(player, {:number, number})
        !finished
      end)

    new_state =
      state |> Map.merge(%{players: players_left, numbers: numbers |> Enum.concat([number])})

    case players_left do
      [] ->
        {:stop, :normal, true, new_state}

      _ ->
        {:reply, false, new_state}
    end
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
