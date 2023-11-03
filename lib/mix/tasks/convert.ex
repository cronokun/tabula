defmodule Mix.Tasks.Convert do
  @moduledoc ~S"""
  Convert single Markdown file to HTML.

  Fetch cards (markdown files) from provided path and genetare HTML files.
  """

  @shortdoc "Convert cards to HTML"

  use Mix.Task

  def run(paths) do
    Tabula.Convert.run(paths)
    IO.puts("DONE!")
  end
end
