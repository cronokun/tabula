defmodule Tabula.IndexPageRenderer do
  @moduledoc ~S"""
  Render index.html page for the board.
  """

  alias Tabula.Markdown.Renderer

  @layout ~S"""
  <!doctype html>
  <html lang="en">
  <head>
      <meta charset=utf-8>
      <title><%= @board_title %></title>
  </head>
  <body>
  <h1>
       <%= @board_title %>
  </h1>
  <%= @inner_content %>
  </body>
  </html>
  """

  def to_html(board) do
    content = lists_to_html(board.lists)
    EEx.eval_string(@layout, assigns: [board_title: board.name, inner_content: content]) |> String.trim_trailing()
  end

  defp lists_to_html(lists) do
    lists
    |> Enum.map(&list_ast/1)
    |> Renderer.to_html()
  end

  defp list_ast(list) do
    [
      {"h2", [], [list.name], %{}},
      {"ul", [], Enum.map(list.cards, &card_ast/1), %{}}
    ]
  end

  defp card_ast(card) do
    {"li", [], [ {"a", [{"href", "#{card.path}.html"}, {"title", card.title}], [card.title], %{}}], %{}}
  end
end
