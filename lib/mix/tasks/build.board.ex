defmodule Mix.Tasks.Build.Board do
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

  @options [verbose: :boolean]

  @impl Mix.Task
  def run(opts) do
    Tabula.Storage.start_link([])

    case OptionParser.parse!(opts, strict: @options) do
      {opts, [dir | _]} -> Tabula.Builder.run(dir, set_defaults(opts))
      {opts, []} -> Tabula.Rebuild.run(set_defaults(opts))
    end

    Mix.shell().info("> Done")
  end

  defp set_defaults(opts) do
    Keyword.put_new(opts, :verbose, false)
  end
end
