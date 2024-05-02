defmodule Tabula.Storage do
  @moduledoc """
  Simple API to access cards data.

  It's used to store card's data (like cover image, due dates and tags) when parsing markdown
  and then retrieve that data when generating board's index page.
  """

  use Agent

  # FIXME: This allowes to store only one board data at a time, so it can't be used
  # to process boards concurently.
  def init(board_name) do
    init_fn = fn -> %{board_name: board_name, cards: %{}} end

    case Agent.start_link(init_fn, name: __MODULE__) do
      {:ok, _pid} -> :ok

      {:error, {:already_started, pid}} ->
          Agent.stop(pid)
          init(board_name)
    end
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
