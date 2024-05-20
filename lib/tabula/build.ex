defmodule Tabula.Build do
  @moduledoc """
  Build the "board": convert MD files to HTML, create `index.html`, copy assets, etc.
  """

  alias Tabula.Board
  alias Tabula.Convert
  alias Tabula.IndexPageRenderer

  def run(board_dir) do
    IO.puts("\nBuilding board \"#{board_dir}\"")

    with {:ok, yml} <- File.read(Path.join(board_dir, "_items.yml")),
         {:ok, data} <- YamlElixir.read_from_string(yml),
         board <- Board.build(data, board_dir) do
      manage_dirs(board)
      create_pages(board)
      create_index_page(board)
    else
      error -> info("Something went wrong: #{inspect(error)}", :error)
    end
  end

  defp create_index_page(board) do
    info("creating index page")
    html = IndexPageRenderer.to_html(board)
    File.write!(board.index_path, html)
    :ok
  end

  defp create_pages(board) do
    info("creating card pages")

    stats =
      for list <- board.lists, card <- list.cards, reduce: %{done: 0, skipped: 0} do
        acc ->
          case Convert.convert_file(card) do
            :skipped ->
              info("WARNING: Can't read file '#{card.source_path}', skipping", :warning)
              Map.update(acc, :skipped, 0, &(&1 + 1))

            _ ->
              Map.update(acc, :done, 0, &(&1 + 1))
          end
      end

    info("#{stats.done} created, #{stats.skipped} skipped")

    :ok
  end

  # FIXME: this is duplicated; move to config!
  @release_dir Path.expand("release")

  defp manage_dirs(board) do
    info("copying assets")
    destination = Path.join([@release_dir, board.name])
    dest_img_dir = Path.join([@release_dir, "assets/images/", board.name])
    source_img_dir = Path.join([board.dir, "_images/"])
    dest_assets_dir = Path.join([@release_dir, "assets/"])
    File.rm_rf!(destination)
    File.mkdir_p!(dest_img_dir)
    File.cp_r!(source_img_dir, dest_img_dir)
    File.cp_r!("assets/", dest_assets_dir)
    for list <- board.lists, do: File.mkdir_p!(Path.join([destination, list.path]))
    :ok
  end

  defp info(message, type \\ :normal, padding \\ "  ")
  defp info(message, :normal, padding), do: IO.puts(padding <> message)

  defp info(message, :error, padding),
    do: IO.puts(IO.ANSI.red() <> padding <> message <> IO.ANSI.reset())

  defp info(message, :warning, padding),
    do: IO.puts(IO.ANSI.yellow() <> padding <> message <> IO.ANSI.reset())
end
