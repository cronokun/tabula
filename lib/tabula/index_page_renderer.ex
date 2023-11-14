defmodule Tabula.IndexPageRenderer do
  @moduledoc ~S"""
  Render index.html page for the board.
  """

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

  def to_html(board) do
    [
      set_page_title(@index_html_layout_before, board.name),
      lists_to_html(board.lists),
      @index_html_layout_after
    ]
  end

  defp lists_to_html(lists) do
    for list <- lists do
      [
        "<h2>#{list.name}</h2>\n",
        "<ul>\n",
        for card <- list.cards do
          card_path = card.path <> ".html"
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
