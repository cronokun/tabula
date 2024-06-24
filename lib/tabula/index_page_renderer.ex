defmodule Tabula.IndexPageRenderer do
  @moduledoc """
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
          {"body", [{"class", css_board_name(board)}],
           [
             {"h1", [], [board.name]},
             lists_to_html(board.lists)
           ]}
        ]
      }
    ])
    |> String.trim_trailing()
  end

  defp lists_to_html(lists) do
    Enum.map(lists, fn list ->
      {"section", [],
       [
         {"h2", [{"id", list.path}],
          [
            list.name,
            list_cards_counter(list)
          ]},
         {"ul", [], Enum.map(list.cards, &card_ast/1)}
       ]}
    end)
  end

  defp card_ast(card) do
    data = Storage.get(card)

    {"li", [{"class", "card"}],
     [
       {"a", [{"href", card.target_path}, {"title", data["title"]}],
        [
          card_cover(data),
          card_title(card, data)
        ]},
       tags_block(data)
     ]}
  end

  defp card_cover(card) do
    {src, class} =
      case card["image_path"] do
        nil -> {"../assets/images/no-cover.png", "no-cover"}
        path -> {"..#{path}", "cover"}
      end

    {"img", [{"src", src}, {"alt", card["title"]}, {"class", class}], []}
  end

  defp card_title(card, data) do
    title = data["title"] || card.name

    case data["subtitle"] do
      nil -> title
      subtitle -> [title, {"span", [{"class", "subtitle"}], [subtitle]}]
    end
  end

  defp css_board_name(board) do
    board.name |> String.downcase() |> String.replace(" ", "-")
  end

  defp tags_block(data) do
    tags = List.wrap(data["tags"]) ++ List.wrap(due_date_tag(data))

    if Enum.empty?(tags) do
      []
    else
      tags_ast = for tag <- tags, do: {"span", [], tag}
      {"p", [{"class", "tags"}], tags_ast}
    end
  end

  defp due_date_tag(%{"due_date" => due_date}) do
    date = Date.from_iso8601!(due_date)
    is_same_year = Date.utc_today().year == date.year

    if is_same_year do
      Calendar.strftime(date, "%b %d")
    else
      Calendar.strftime(date, "%b %d, %y")
    end
  end

  defp due_date_tag(_context), do: nil

  defp list_cards_counter(%{cards: cards}) do
    case length(cards) do
      0 -> []
      1 -> {"span", [{"class", "count"}], ["1 card"]}
      n -> {"span", [{"class", "count"}], ["#{n} cards"]}
    end
  end
end
