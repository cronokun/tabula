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
             navbar(board),
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
       {"ol", [{"class", "cards grid"}], Enum.map(list.cards, &card_ast/1)}
     ]}
  end

  defp list_header(list) do
    counter_text =
      case length(list.cards) do
        0 -> "Nothing yet"
        1 -> "1 card"
        n -> "#{n} cards"
      end

    [
      {"h2", [{"id", list.base_path}], [list.name]},
      {"span", [{"class", "count"}], [counter_text]}
    ]
  end

  defp card_ast(card) do
    card = Storage.get(card.id) || card

    {
      "li",
      [{"class", "card"}],
      [
        {"div", [{"class", "card-wrap"}],
         [
           card_image(card),
           card_title(card),
           card_tags(card)
         ]}
      ]
    }
  end

  defp card_image(card) do
    if card.exists do
      {"a", [{"href", card.link_path}, {"title", card.title}], [card_cover(card)]}
    else
      card_cover(card)
    end
  end

  defp card_cover(card) do
    {src, class} = get_card_image(card)

    {
      "img",
      [{"src", src}, {"alt", card.title}, {"class", class}, {"loading", "lazy"}],
      []
    }
  end

  defp get_card_image(%{image_path: src}) when is_binary(src), do: {src, "cover"}
  defp get_card_image(%{default_image_path: src}) when is_binary(src), do: {src, "no-cover"}
  defp get_card_image(_card), do: {"/assets/images/no-cover.png", "no-cover"}

  defp card_title(card) do
    title_tag = {"span", [{"class", "title"}], [card.title]}
    subtitle = card.subtitle || "&nbsp;"
    rating_class = if card.subtitle, do: "rating", else: "rating without-subtitle"
    rating_tag = {"i", [{"class", rating_class}], [card.rating]}

    case {card.subtitle, card.rating} do
      {nil, nil} ->
        [title_tag]

      {_, nil} ->
        [
          title_tag,
          {"span", [{"class", "subtitle"}], [subtitle]}
        ]

      _ ->
        [
          title_tag,
          {"span", [{"class", "subtitle"}], [subtitle, rating_tag]}
        ]
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

  defp navbar(board) do
    index_link = {"a", [{"href", "/index.html"}], ["Boards"]}

    edit_link =
      {"a", [{"href", open_in_mvim(board.source_path)}, {"class", "edit-btn"}], ["Edit board"]}

    {"nav", [],
     [
       {"ol", [],
        [
          {"li", [], [index_link]},
          {"li", [{"class", "current"}], [board.title]}
        ]},
       edit_link
     ]}
  end
end
