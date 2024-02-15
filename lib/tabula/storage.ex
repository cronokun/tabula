defmodule Tabula.Storage do
  @moduledoc ~S"""
  Simple API to store card's data.
  """

  use Agent

  def init(board_name) do
    Agent.start_link(fn -> %{board_name: board_name, cards: %{}} end, name: __MODULE__)
  end

  def add_card(card) do
    Agent.update(__MODULE__, fn board ->
      put_in(board, [:cards, card["title"]], card)
    end)
  end

  def get_card(card_name) do
    Agent.get(__MODULE__, fn board -> Map.get(board.cards, card_name) end)
  end

  def board_name do
    Agent.get(__MODULE__, fn board -> board[:board_name] end)
  end

  def cards do
    Agent.get(__MODULE__, & &1)
  end
end
