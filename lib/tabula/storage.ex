defmodule Tabula.Storage do
  @moduledoc """
  Simple API to access cards data.

  It's used to store card's data (like cover image, due dates and tags) when parsing markdown
  and then retrieve that data when generating board's index page.
  """

  use GenServer

  @table :tabula_cards

  def get(card_id), do: GenServer.call(__MODULE__, {:get, card_id})
  def put(card, data), do: GenServer.call(__MODULE__, {:put, card, data})

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    :ets.new(@table, [:named_table])
    {:ok, nil}
  end

  @impl true
  def handle_call({:get, card_id}, _from, state) do
    data =
      case :ets.lookup(@table, card_id) do
        [] -> nil
        [{_key, data}] -> data
      end

    {:reply, data, state}
  end

  @impl true
  def handle_call({:put, card, data}, _from, state) do
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

    {:reply, :ok, state}
  end
end
