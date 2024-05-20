defmodule Mix.Tasks.Build do
  @moduledoc """
  Build website for the specified board.

    $ mix build BOARD_DIR_PATH

  Running this will:

  1. create index.html file;
  2. create dirs structure for lists;
  3. create HTML pages for each card;
  4. copy assets.

  Output dir will be `release/BOARD_NAME/`.
  """

  @shortdoc "Build board"

  use Mix.Task

  @impl Mix.Task
  def run(opts) do
    Tabula.Storage.init()

    case parse_options(opts) do
      [path: path] -> Tabula.Build.run(path)
      [] -> for path <- all_boards(), do: Tabula.Build.run(path)
    end

    IO.puts("\nDONE!")
  end

  defp all_boards do
    File.ls!("priv/boards/")
    |> Enum.map(&"priv/boards/#{&1}")
    |> Enum.filter(&File.dir?/1)
  end

  defp parse_options(opts) do
    OptionParser.parse(opts, strict: [path: :string]) |> elem(0)
  end
end
