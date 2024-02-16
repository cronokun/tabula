defmodule Tabula.Build do
  @moduledoc ~S"""
  Build the "board": convert MD files to HTML, create `index.html`, copy assets, etc.
  """

  alias Tabula.Board
  alias Tabula.Convert
  alias Tabula.IndexPageRenderer
  alias Tabula.Storage

  def run(board_dir) do
    with {:ok, yml} <- File.read(Path.join(board_dir, "_items.yml")),
         {:ok, data} <- YamlElixir.read_from_string(yml),
         board <- Board.build(data, board_dir) do
      Storage.init(board.name)
      manage_dirs(board)
      create_pages(board)
      create_index_page(board)
    end
  end

  defp create_index_page(board) do
    IO.puts("creating index page")
    html = IndexPageRenderer.to_html(board)
    File.write!(board.index_path, html)
    :ok
  end

  defp create_pages(board) do
    for list <- board.lists, card <- list.cards do
      IO.puts("creating \"#{card.name}\" card")
      result = Convert.convert_file(card)

      if result == :skipped do
        IO.puts("#{IO.ANSI.yellow()}WARNING: Can't read file, skipping#{IO.ANSI.reset()}")
      end
    end

    :ok
  end

  # FIXME: this is duplicated; move to config!
  @release_dir Path.expand("release")

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
end
