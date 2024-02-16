defmodule Tabula.Storage do
  @moduledoc ~S"""
  Simple API to access cards data.

  It's used to store card's data (like cover image, due dates and tags) when parsing markdown
  and then retrieve that data when generating board's index page.
  """

  use Agent

  def init(board_name) do
    Agent.start_link(fn -> %{board_name: board_name, cards: %{}} end, name: __MODULE__)
  end

  def add_card(title, card) do
    Agent.update(__MODULE__, fn board -> put_in(board, [:cards, title], card) end)
  end

  def get_card(card_name) do
    Agent.get(__MODULE__, fn board -> board.cards[card_name] end)
  end

  def board_name do
    Agent.get(__MODULE__, fn board -> board[:board_name] end)
  end

  def cards do
    Agent.get(__MODULE__, & &1)
  end
end
