defmodule Tabula.Rebuild do
  @moduledoc "Rebuild all boards and global index page."

  @boards_dir Application.compile_env(:tabula, :base_boards_dir)

  import Tabula.Utils, only: [list_dirs: 1]

  require Logger

  use Task

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(opts) do
    Logger.info("Building all boards in #{@boards_dir}")
    for board <- list_dirs(@boards_dir), do: Tabula.Builder.run(board, opts)
    Tabula.GlobalIndex.create()
    :ok
  end
end
