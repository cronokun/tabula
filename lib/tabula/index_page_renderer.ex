defmodule Tabula.IndexPageRenderer do
  @moduledoc ~S"""
  Render index.html page for the board.
  """

  alias Tabula.Markdown.Renderer
  alias Tabula.Storage

  def to_html(board) do
    Renderer.to_html([
      {"doctype", [], []},
      {
        "html",
        [{"lang", "en"}],
        [
          {"head", [],
           [
             {"meta", [{"charset", "utf-8"}], []},
             {"link", [{"rel", "stylesheet"}, {"href", "../assets/css/board.css"}], []},
             {"title", [], [board.name]}
           ]},
          {"body", [],
           [
             {"h1", [], [board.name]},
             lists_to_html(board.lists)
           ]}
        ]
      }
    ])
    |> String.trim_trailing()
  end

  defp lists_to_html(lists), do: Enum.map(lists, &list_ast/1)

  defp list_ast(list) do
    {"section", [],
     [
       {"h2", [], [list.name]},
       {"ul", [], Enum.map(list.cards, &card_ast/1)}
     ]}
  end

  defp card_ast(card) do
    data = Storage.get_card(card.name)

    {"li", [{"class", "card"}],
     [
       {"a", [{"href", card.target_path}, {"title", data["title"]}],
        [card_cover(data), data["title"] || card.name]}
     ]}
  end

  defp card_cover(card) do
    src =
      case card["image_path"] do
        nil -> "../assets/images/no-cover.jpeg"
        path -> "..#{path}"
      end

    {"img", [{"src", src}, {"alt", card["title"]}, {"class", "cover"}], []}
  end
end
