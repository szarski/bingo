defmodule Bingo do
  require Application

  def start(_, _) do
    GameSet.start_link()
  end
end
