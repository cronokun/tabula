defmodule Tabula.Convert do
  @moduledoc ~S"""
  Create HTML files from Markdown cards. This is simple orchestrating module, all real work is done in other modules.

  TODO: add tests.
  """

  alias Tabula.Board.Card
  alias Tabula.Markdown.Parser
  alias Tabula.Markdown.Renderer
  alias Tabula.AstPostProcessor

  def convert_file(card) when is_struct(card, Card) do
    case File.read(card.source_path) do
      {:ok, content} ->
        {markdown, context} = maybe_parse_front_matter(content)

        html =
          markdown
          |> Parser.parse()
          |> AstPostProcessor.modify_ast(card, context)
          |> Renderer.to_html()

        File.write!(card.target_path, html)

      {:error, _} ->
        :skipped
    end
  end

  @front_matter_spliter ~r/\n?---\n/

  defp maybe_parse_front_matter(content) do
    case String.split(content, @front_matter_spliter, trim: true) do
      [markdown] ->
        {markdown, %{}}

      [yaml, markdown] ->
        {:ok, front_matter} = YamlElixir.read_from_string(yaml)
        {markdown, front_matter}
    end
  end
end
