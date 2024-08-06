defmodule Tabula.Storage do
  @moduledoc """
  Simple API to access cards data.

  It's used to store card's data (like cover image, due dates and tags) when parsing markdown
  and then retrieve that data when generating board's index page.
  """

  @table :tabula_cards

  def init, do: :ets.new(@table, [:named_table])

  def get(card_id) do
    case :ets.lookup(@table, card_id) do
      [] -> nil
      [{_key, data}] -> data
    end
  end

  def put(card, data) do
    card =
      Map.merge(card, %{
        created_at: data["created_at"],
        updated_at: data["updated_at"],
        tags: data["tags"],
        title: data["title"],
        subtitle: data["subtitle"],
        image_path: data["image_path"],
        exists: true
      })

    :ets.insert(@table, {card.id, card})
  end
end
