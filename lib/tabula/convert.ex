defmodule Tabula.Convert do
  @moduledoc ~S"""
  Create HTML files from Markdown cards.
  """

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
      |> process_front_matter()
      |> parse()
      |> wrap_content()

    File.write!(output_path, html_content)
  end

  # If file starts with "---\n" extract YAML front matter
  defp process_front_matter("---\n" <> content) do
    with [yaml, content] <- String.split(content, "\n---\n"),
         {:ok, front_matter} <- YamlElixir.read_from_string(yaml) do
      {front_matter, content}
    end
  end

  defp process_front_matter(content), do: {%{}, content}

  defp parse({front_matter, content}) do
    {front_matter, Earmark.as_html!(content)}
  end

  @html_layout_before ~S"""
  <!doctype html>
  <html lang="en">
  <head>
    <meta charset=utf-8>
    <title><%= @title %></title>
  </head>
  <body>
  """

  @html_layout_after ~S"""
  </body>
  </html>
  """

  defp wrap_content({front_matter, content}) do
    [
      @html_layout_before |> update_title(front_matter),
      content,
      @html_layout_after
    ]
  end

  defp update_title(layout, front_matter) do
    title = Map.get(front_matter, "title", "Untitled")
    # FIXME: this is very naive!
    String.replace(layout, "<%= @title %>", title)
  end
end
