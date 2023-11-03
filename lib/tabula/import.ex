defmodule Tabula.Import do
  @moduledoc ~S"""
  Import data from Trello.

  Read and parse JSON file, create Markdown files for each card.

  Output structure:

  priv/import/
  └── <board-name>/
      ├── <list-name>/
      │     ├── <card-name>.md
      │     ├── <card-name>.md
      │     ├── <card-name>.md
      │     └── <card-name>.md
      └── <list-name>/
            ├── <card-name>.md
            ├── <card-name>.md
            └── <card-name>.md
  """

  alias Tabula.Import.TrelloJsonParser, as: Parser
  alias Tabula.Import.MarkdownGenerator, as: Generator

  def run(filepath) do
    {:ok, data} = Parser.parse(filepath)

    board_name = data.name

    for list <- data.lists, do: import_list!(list, board_name)
  end

  defp import_list!(%{name: list_name, cards: cards}, board_name) do
    create_list_dir!(board_name, list_name)

    for card <- cards do
      card
      |> Generator.generate()
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
    path |> String.replace([":"], "") |> String.replace("/", " - ")
  end
end
