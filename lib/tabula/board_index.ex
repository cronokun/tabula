defmodule Tabula.BoardIndex do
  @moduledoc "Create a board index page."

  alias Tabula.Markdown.Renderer
  alias Tabula.Storage

  import Tabula.Utils, only: [open_in_mvim: 1]

  def create(board) do
    html =
      board
      |> generate_ast()
      |> Renderer.to_html()

    File.write!(board.index_page_path, html)
  end

  def generate_ast(board) do
    [
      {"doctype", [], []},
      {
        "html",
        [{"lang", "en"}],
        [
          {"head", [],
           [
             {"meta", [{"charset", "utf-8"}], []},
             {"link", [{"rel", "stylesheet"}, {"href", "/assets/css/board.css"}], []},
             {"title", [], [board.title]}
           ]},
          {"body", [{"class", board.base_path}],
           [
             {"h1", [],
              [
                board.title,
                {"a", [{"href", open_in_mvim(board.source_path)}, {"class", "edit-btn"}],
                 ["Edit board"]}
              ]},
             Enum.map(board.lists, &list_ast/1)
           ]}
        ]
      }
    ]
  end

  defp list_ast(list) do
    {"section", [],
     [
       list_header(list),
       {"ul", [], Enum.map(list.cards, &card_ast/1)}
     ]}
  end

  defp list_header(list) do
    cards_counter =
      case length(list.cards) do
        0 -> []
        1 -> {"span", [{"class", "count"}], ["1 card"]}
        n -> {"span", [{"class", "count"}], ["#{n} cards"]}
      end

    {"h2", [{"id", list.base_path}], [list.name, cards_counter]}
  end

  defp card_ast(card) do
    card = Storage.get(card.id) || card

    {
      "li",
      [{"class", "card"}],
      [
        card_link(card),
        card_tags(card)
      ]
    }
  end

  defp card_link(card) do
    case card.exists do
      true ->
        {
          "a",
          [{"href", card.link_path}, {"title", card.title}],
          [
            card_cover(card),
            card_title(card)
          ]
        }

      false ->
        [
          card_cover(card),
          card_title(card)
        ]
    end
  end

  defp card_cover(card) do
    {src, class} =
      case card.image_path do
        nil -> {"/assets/images/no-cover.png", "no-cover"}
        path -> {path, "cover"}
      end

    {
      "img",
      [{"src", src}, {"alt", card.title}, {"class", class}, {"loading", "lazy"}],
      []
    }
  end

  defp card_title(card) do
    case card.subtitle do
      nil -> card.title
      subtitle -> [card.title, {"span", [{"class", "subtitle"}], [subtitle]}]
    end
  end

  def card_tags(card) do
    case card.tags do
      [] ->
        []

      tags ->
        {"p", [{"class", "tags"}], for(tag <- tags, do: {"span", [], tag})}
    end
  end
end
