defmodule Mix.Tasks.Import do
  @moduledoc """
  Import cards from JSON file from Trello.

      $ mix import PATH

  It reads data from provided JSON file and creates cards in `priv/import/<board-name>/`.
  If file already exists, it will be overwriten.
  """

  @shortdoc "Import cards from Trello"

  use Mix.Task

  @impl Mix.Task
  def run([path | _rest]) do
    Tabula.Import.run(path)
    IO.puts("DONE!")
  end
end
