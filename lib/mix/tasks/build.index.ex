defmodule Mix.Tasks.Build.Index do
  @moduledoc """
  Build and render a global index page.

  This will create a `release/index.html` file with list of all boards,
  board lists and number of cards in each list.
  """

  @shortdoc "Build global index page"

  use Mix.Task

  @impl Mix.Task
  def run(_) do
    Mix.shell().info("\n> Buiding global index page...")
    Tabula.GlobalIndex.create()
    Mix.shell().info("> Done")
  end
end
