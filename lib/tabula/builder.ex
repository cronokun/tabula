defmodule Tabula.Builder do
  @moduledoc """
  Build the "board": convert MD files to HTML, create `index.html`, copy assets, etc.
  """

  require Logger

  alias Tabula.{Board, BoardIndex, Card}

  @release_dir Application.compile_env(:tabula, :release_dir)

  def run(dir, _opts \\ []) do
    Logger.info("Building board '#{Path.basename(dir)}'")
    board = Board.build(dir)
    copy_assets!(board)
    convert_cards(board)
    create_board_index_page(board)
    :ok
  end

  defp copy_assets!(board) do
    priv_dir = :code.priv_dir(:tabula)
    source_css_dir = Path.join(priv_dir, "/static/assets/css/")
    source_img_dir = Path.join(priv_dir, "/static/assets/images/")
    target_css_dir = Path.join(@release_dir, "/assets/css/")
    target_img_dir = Path.join(@release_dir, "/assets/images/")

    File.mkdir_p!(target_css_dir)
    File.mkdir_p!(target_img_dir)
    File.cp_r!(source_css_dir, target_css_dir)
    File.cp_r!(source_img_dir, target_img_dir)

    File.rm_rf!(board.target_dir)
    File.mkdir_p!(board.target_dir)
    File.rm_rf!(board.assets_target_path)
    File.mkdir_p!(board.assets_target_path)
    File.cp_r!(board.assets_source_path, board.assets_target_path)
  end

  defp convert_cards(board) do
    for list <- board.lists do
      File.mkdir_p!(list.target_path)

      for card <- list.cards do
        case Card.convert(card) do
          :skipped -> IO.puts("\e[2mskipped #{card.source_path}\e[0m")
          html -> File.write!(card.target_path, html)
        end
      end
    end
  end

  defp create_board_index_page(board), do: BoardIndex.create(board)
end
