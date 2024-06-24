defmodule Mix.Tasks.Build.Index do
  @moduledoc """
  Build and render a global index page.

  This will create a `release/index.html` file with list of all boards,
  board lists and number of cards in each list.
  """

  use Mix.Task

  @shortdoc "Build global index page"

  @impl Mix.Task
  def run(_) do
    Tabula.BuildIndex.run()
  end
end
