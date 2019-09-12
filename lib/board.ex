defmodule Board do
  def generate do
    1..5
    |> Enum.map(fn row ->
      1..5
      |> Enum.map(fn _ ->
        (row - 1) * 20 + Enum.random(1..20)
      end)
    end)
  end

  def to_s(board) do
    str =
      board
      |> Enum.map(&Kernel.inspect(&1, charlists: :as_lists))
      |> Enum.join("\n")

    "\n  B   I   N   G   O\n#{str}"
  end

  def bingo?(board, numbers) do
    hits =
      board
      |> Enum.map(fn row ->
        row
        |> Enum.map(fn cell ->
          Enum.member?(numbers, cell)
        end)
      end)

    possible_lines =
      Enum.concat([
        hits,
        1..5 |> Enum.map(fn i -> Enum.map(hits, fn hit_row -> hit_row |> Enum.at(i - 1) end) end)
      ])

    possible_lines
    |> Enum.map(fn line -> !Enum.member?(line, false) end)
    |> Enum.member?(true)
  end
end
