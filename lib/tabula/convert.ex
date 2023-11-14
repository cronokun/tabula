defmodule Tabula.Convert do
  @moduledoc ~S"""
  Create HTML files from Markdown cards.
  """

  alias Tabula.Markdown.Parser
  alias Tabula.Markdown.Renderer

  def run(paths) when is_list(paths) do
    for filepath <- paths do
      IO.puts("converting card: #{filepath}")
      convert_file(filepath)
    end
  end

  def convert_file(input_path) do
    output_path = String.replace(input_path, ~r/\.(md|markdown)$/, ".html")
    convert_file(input_path, output_path)
  end

  def convert_file(input_path, output_path) do
    html_content =
      input_path
      |> File.read!()
      |> parse_front_matter()
      |> process_front_matter()
      |> convert()

    File.write!(output_path, html_content)
  end

  # If file starts with "---\n" extract YAML front matter
  defp parse_front_matter("---\n" <> content) do
    with [yaml, content] <- String.split(content, "\n---\n"),
         {:ok, front_matter} <- YamlElixir.read_from_string(yaml) do
      {front_matter, content}
    end
  end

  defp parse_front_matter(content), do: {%{}, content}

  defp process_front_matter({context, content}) do
    context =
      context
      |> Map.put("title", get_title_from_header(content))
      |> Map.put("tags", split_tags(context))

    {context, content}
  end

  defp get_title_from_header(content) do
    case Regex.run(~r/^# ([^\n]+)\n/, content, capture: :all_but_first) do
      [title] -> title
      nil -> "Untitled"
    end
  end

  defp split_tags(context) do
    Map.update(context, "tags", [], fn tags -> String.split(tags || "", ", ") end)
  end

  defp convert({context, content}) do
    with ast <- Parser.parse(content),
         html <- Renderer.to_html(ast, context) do
      html
    end
  end
end
