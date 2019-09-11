defmodule Bingo do
  require Application

  def start(_, _) do
    Game.start_link()
  end
end
