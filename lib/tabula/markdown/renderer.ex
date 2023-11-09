defmodule Tabula.Markdown.Renderer do
  @moduledoc ~S"""
  Render AST to HTML and wrap it in a HTML document.
  """

  def to_html(ast, context \\ %{}) do
    {:ok, options} = Earmark.Options.make_options(compact_output: true)

    ast
    |> Earmark.Transform.transform(options)
    |> into_html_document(context)
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

  defp into_html_document(content, context) do
    [
      update_title(@html_layout_before, context),
      content,
      @html_layout_after
    ]
  end

  defp update_title(layout, %{"title" => title}) do
    # FIXME: this is very naive!
    String.replace(layout, "<%= @title %>", title)
  end
end
