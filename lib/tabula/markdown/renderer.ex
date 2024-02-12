defmodule Tabula.Markdown.Renderer do
  @moduledoc ~S"""
  Render AST to HTML and wrap it in a HTML document.
  """

  def to_html(ast, context \\ %{}, layout \\ false) do
    opts = %{level: 0, pad: "    ", inline: false}
    html = ast_to_string(ast, opts)

    if layout do
      into_html_document(html, context)
    else
      html
    end
  end

  @contentless_tags ~w[area base br col command embed hr img input keygen link meta param source track wbr]
  @inline_tags ~w[a b dd dt i span strong]

  defp ast_to_string(list, opts) when is_list(list),
    do: Enum.map_join(list, "", &ast_to_string(&1, opts))

  defp ast_to_string(binary, opts) when is_binary(binary), do: pad_line(binary, opts)

  defp ast_to_string({"comment", _attrs, inner, _meta}, opts),
    do: pad_line("<!--#{inner}-->", opts)

  defp ast_to_string({tag, attrs, _inner, _meta}, opts)
       when tag in @contentless_tags,
       do: pad_line("<#{tag}#{attrs_to_string(attrs)}>", opts)

  defp ast_to_string({"li", _attrs, [content | _rest], _meta} = ast, %{inline: false} = opts)
       when is_binary(content),
       do: ast_to_string(ast, %{opts | inline: true})

  defp ast_to_string({tag, _attrs, _inner, _meta} = ast, %{inline: false} = opts)
       when tag in @inline_tags,
       do: ast_to_string(ast, %{opts | inline: true})

  defp ast_to_string({tag, attrs, inner, _meta}, %{inline: true} = opts) do
    pad_line("<#{tag}#{attrs_to_string(attrs)}>", opts) <>
      ast_to_string(inner, Map.put(opts, :level, 0)) <>
      "</#{tag}>" <> "\n"
  end

  defp ast_to_string({tag, attrs, inner, _meta}, opts) do
    next_opts = Map.update!(opts, :level, &(&1 + 1))

    pad_line("<#{tag}#{attrs_to_string(attrs)}>", opts) <>
      ast_to_string(inner, next_opts) <>
      pad_line("</#{tag}>", opts)
  end

  defp attrs_to_string(attrs) when is_list(attrs) do
    Enum.map(attrs, fn {key, val} -> " #{key}=\"#{val}\"" end)
  end

  defp pad_line(line, %{level: level, pad: padding, inline: true}),
    do: String.duplicate(padding, level) <> line

  defp pad_line(line, %{level: level, pad: padding, inline: false}),
    do: String.duplicate(padding, level) <> line <> "\n"

  # --- Etc ---

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
    IO.iodata_to_binary([
      update_title(@html_layout_before, context),
      content,
      @html_layout_after
    ])
  end

  defp update_title(layout, %{"title" => title}) do
    # FIXME: this is very naive!
    String.replace(layout, "<%= @title %>", title)
  end
end
