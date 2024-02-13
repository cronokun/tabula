defmodule Tabula.Build do
  @moduledoc ~S"""
  Build the "board": convert MD files to HTML, create `index.html`, copy assets, etc.
  """

  alias Tabula.Board
  alias Tabula.Convert
  alias Tabula.IndexPageRenderer

  def run(board_dir) do
    with {:ok, yml} <- File.read(Path.join(board_dir, "_items.yml")),
         {:ok, data} <- YamlElixir.read_from_string(yml),
         board <- Board.build(data, board_dir) do
      manage_dirs(board)
      create_pages(board)
      create_index_page(board)
    end
  end

  @release_dir Path.expand("release")

  defp create_index_page(board) do
    html = IndexPageRenderer.to_html(board)
    path = Path.join([@release_dir, board.name, "index.html"])
    IO.puts("building index page")
    File.write!(path, html)
    :ok
  end

  defp create_pages(board) do
    for list <- board.lists, card <- list.cards do
      IO.puts("building \"#{card.path}\"")

      card_path = card_source_path(board, card)
      output_path = card_dest_path(board, card)
      opts = %{board_name: board.name}
      result = Convert.convert_file(card_path, output_path, opts)

      if result == :skipped do
        IO.puts("#{IO.ANSI.yellow()}WARNING: Can't read file, skipping#{IO.ANSI.reset()}")
      end
    end

    :ok
  end

  defp manage_dirs(board) do
    IO.puts("copying assets")
    destination = Path.join([@release_dir, board.name])
    dest_img_dir = Path.join([@release_dir, "assets/images/", board.name])
    source_img_dir = Path.join([board.dir, "_images/"])
    dest_css_dir = Path.join([@release_dir, "assets/css/"])
    File.rm_rf!(destination)
    File.mkdir_p!(dest_img_dir)
    File.cp_r!(source_img_dir, dest_img_dir)
    File.cp_r!("assets/css/", dest_css_dir)
    for list <- board.lists, do: File.mkdir_p!(Path.join([destination, list.path]))
    :ok
  end

  def card_source_path(board, card) do
    [board.dir, card.path <> ".md"]
    |> Path.join()
    |> Path.expand()
  end

  def card_dest_path(board, card) do
    [@release_dir, board.name, card.path <> ".html"]
    |> Path.join()
    |> Path.expand()
  end
end
