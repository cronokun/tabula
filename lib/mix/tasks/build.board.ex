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

  @requirements ["app.start"]

  # FIXME: move to config
  @boards_dir "/Users/cronokun/Documents/Boards/"
  @options [verbose: :boolean]

  @impl Mix.Task
  def run(opts) do
    case OptionParser.parse!(opts, strict: @options) do
      {opts, [dir | _]} ->
        Tabula.Builder.run(dir, set_defaults(opts))

      {opts, []} ->
        opts = set_defaults(opts)

        for dir <- list_all_boards() do
          Tabula.Builder.run(dir, opts)
        end
    end

    Mix.shell().info("\nDONE!")
  end

  defp list_all_boards do
    @boards_dir
    |> File.ls!()
    |> Enum.reduce([], fn fname, acc ->
      fpath = Path.join([@boards_dir, fname])

      if not String.starts_with?(fname, ".") and File.dir?(fpath) do
        [fpath | acc]
      else
        acc
      end
    end)
  end

  defp set_defaults(opts) do
    Keyword.put_new(opts, :verbose, false)
  end
end
