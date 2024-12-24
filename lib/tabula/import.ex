defmodule Tabula.Import do
  @moduledoc "Import board from Trello."

  alias Tabula.Trello.Generator
  alias Tabula.Trello.JsonParser

  def run(file) do
    {:ok, board} = JsonParser.parse(file)

    for list <- board.lists, do: import_list!(list, board.name)
  end

  defp import_list!(%{name: list_name, cards: cards}, board_name) do
    create_list_dir!(board_name, list_name)

    for card <- cards do
      card
      |> Generator.to_markdown()
      |> create_card_file!({board_name, list_name, card.name})
    end
  end

  defp create_list_dir!(board_name, list_name) do
    [
      "priv",
      "import",
      safe_path(board_name),
      safe_path(list_name)
    ]
    |> Path.join()
    |> File.mkdir_p!()
  end

  defp create_card_file!(content, {board_name, list_name, card_name}) do
    [
      "priv",
      "import",
      safe_path(board_name),
      safe_path(list_name),
      [safe_path(card_name), ".md"]
    ]
    |> Path.join()
    |> IO.inspect(label: "importing card")
    |> File.write!(content)
  end

  defp safe_path(path) when is_binary(path) do
    path |> String.replace(":", "") |> String.replace("/", " - ")
  end
end
