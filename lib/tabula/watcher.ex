defmodule Tabula.Watcher do
  require Logger

  use GenServer

  @dirs ["/Users/cronokun/Documents/Boards/"]

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_args) do
    {:ok, pid} = FileSystem.start_link(dirs: @dirs)
    FileSystem.subscribe(pid)
    {:ok, %{pid: pid}}
  end

  def handle_info({:file_event, pid, {path, events}}, %{pid: pid} = state) do
    Logger.info("Files changed: #{path} #{inspect(events)}")

    if String.ends_with?(path, ".md") and events == [:renamed] do
      board_path = Path.expand("../..", path)
      Tabula.Builder.run(board_path)
    end

    if String.ends_with?(path, "_items.yml") and :created in events do
      board_path = Path.expand("..", path)
      Tabula.Builder.run(board_path)
      Tabula.GlobalIndex.create()
    end

    {:noreply, state}
  end
end
