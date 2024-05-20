defmodule Tabula.Storage do
  @moduledoc """
  Simple API to access cards data.

  It's used to store card's data (like cover image, due dates and tags) when parsing markdown
  and then retrieve that data when generating board's index page.
  """

  alias Tabula.Board.Card

  @table :tabula_cards

  def init, do: :ets.new(@table, [:named_table])

  def get(card) when is_struct(card, Card) do
    case :ets.lookup(@table, {card.board, card.name}) do
      [] -> nil
      [{_key, data}] -> data
    end
  end

  def put(card, data) when is_struct(card, Card) do
    :ets.insert(@table, {{card.board, card.name}, data})
  end
end
