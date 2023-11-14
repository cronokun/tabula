defmodule Tabula.Builder do
  @moduledoc ~S"""
  Build as "site" or "board": convert MD files to HTML, create `index.html`,
  copy assets, etc.
  """

  alias Tabula.Board

  def run(board_path) do
    with {:ok, yml} <- File.read(board_path),
         {:ok, data} <- YamlElixir.read_from_string(yml),
         board <- Board.build(data, Path.dirname(board_path)),
         :ok <- create_index_page(board) do
      :ok
    end
  end

  @index_html_layout_before ~S"""
  <!doctype html>
  <html lang="en">
  <head>
    <meta charset=utf-8>
    <title><%= @board_title %></title>
  </head>
  <body>
  <h1><%= @board_title %></h1>
  """

  @index_html_layout_after ~S"""
  </body>
  </html>
  """

  defp create_index_page(board) do
    html = [
      set_page_title(@index_html_layout_before, board.name),
      lists_to_html(board.lists),
      @index_html_layout_after
    ]

    path = Path.join(board.dir, "index.html")
    File.write!(path, html)
    :ok
  end

  defp lists_to_html(lists) do
    for list <- lists do
      [
        "<h2>#{list.name}</h2>\n",
        "<ul>\n",
        for card <- list.cards do
          card_path = "file:///Users/crono/Developer/tabula/priv/_boards/" <> card.path <> ".html"
          ~s(<li><a href="#{card_path}" title="#{card.title}">#{card.title}</a></li>\n)
        end,
        "</ul>\n"
      ]
    end
  end

  defp set_page_title(html, title) do
    String.replace(html, "<%= @board_title %>", title)
  end
end
