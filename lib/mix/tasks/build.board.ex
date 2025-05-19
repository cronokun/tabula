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
      {opts, [dir | _]} ->
        Mix.shell().info("\n> Building board in #{dir}")
        Tabula.Builder.run(dir, set_defaults(opts))

      {opts, []} ->
        Mix.shell().info("\n> Building all boards")
        opts = set_defaults(opts)

        for dir <- list_all_boards() do
          Tabula.Builder.run(dir, opts)
        end
    end

    Mix.shell().info("> Done")
  end

  @boards_dir Application.compile_env(:tabula, :base_boards_dir)

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
