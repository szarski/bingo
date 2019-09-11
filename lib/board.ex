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

  def inspect(board) do
    str =
      board
      |> Enum.map(&Kernel.inspect(&1, charlists: :as_lists))
      |> Enum.join("\n")

    "\n  B   I   N   G   O\n#{str}"
  end
end
