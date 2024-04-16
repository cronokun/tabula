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
  def run([path | _rest]) do
    Tabula.Build.run(path)
    IO.puts("DONE!")
  end
end
