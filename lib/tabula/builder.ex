defmodule Tabula.Builder do
  @moduledoc """
  Build the "board": convert MD files to HTML, create `index.html`, copy assets, etc.
  """

  alias Tabula.{Board, BoardIndex, Card}

  def run(dir, _opts) do
    Mix.shell().info("Building board '#{Path.basename(dir)}'")
    board = Board.build(dir)
    copy_assets!(board)
    convert_cards(board)
    create_board_index_page(board)

    :ok
  end

  defp copy_assets!(board) do
    copy_global_assets!()
    File.rm_rf!(board.base_path)
    File.mkdir_p!(board.base_path)
    File.rm_rf!(board.assets_target_path)
    File.mkdir_p!(board.assets_target_path)
    File.cp_r!(board.assets_source_path, board.assets_target_path)
  end

  defp copy_global_assets! do
    File.mkdir_p!("./release/assets/css/")
    File.mkdir_p!("./release/assets/images/")
    File.cp_r!("./assets/css/", "./release/assets/css/")
    File.cp_r!("./assets/images/", "./release/assets/images/")
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
