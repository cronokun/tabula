defmodule Tabula.Markdown.PostProcessor do
  @moduledoc """
  Do some AST post-processing:

  1. Wrap card's AST info HTML document;
  2. Insert tags;
  3. Expand image path.
  """

  alias Tabula.Storage

  import Tabula.Utils, only: [open_in_mvim: 1, snd: 1]

  def modify_ast(ast, context) do
    ast
    |> into_html_layout(context)
    |> expand_image_src(context)
    |> expand_links(context)
    |> insert_tags(context)
  end

  # ---- AST manipulation ----

  defp into_html_layout(inner_ast, %{"title" => title} = context) do
    [
      {"doctype", [], []},
      {"html", [{"lang", "en"}],
       [
         {"head", [],
          [
            {"meta", [{"charset", "utf-8"}], []},
            {"link", [{"rel", "stylesheet"}, {"href", "/assets/css/card.css"}], []},
            {"title", [], [title]}
          ]},
         {"body", [],
          [
            navbar(context),
            {"main", [], inner_ast}
          ]}
       ]}
    ]
  end

  defp navbar(context) do
    index_link = {"a", [{"href", "/index.html"}], ["Boards"]}
    board_link = {"a", [{"href", context["board_url"]}], [context["board_name"]]}
    list_link = {"a", [{"href", context["list_url"]}], [context["list_name"]]}

    {"nav", [],
     [
       {"ol", [],
        [
          {"li", [], [index_link]},
          {"li", [], [board_link]},
          {"li", [], [list_link]}
        ]},
       {"a", [{"href", open_in_mvim(context["source"])}, {"class", "edit-btn"}], ["Edit card"]}
     ]}
  end

  defp insert_tags(ast, %{"tags" => tags}) do
    tags_list = for(tag <- tags, do: {"span", [], [tag]})
    tags_ast = {"p", [{"class", "tags"}], tags_list}

    Floki.traverse_and_update(ast, fn
      {"img", attrs, []} -> [{"img", attrs, []}, tags_ast]
      other -> other
    end)
  end

  @cover_image_selector "h1 ~ p:first-of-type img"

  defp expand_image_src(ast, %{"image_path" => img}) when is_binary(img) do
    Floki.find_and_update(ast, @cover_image_selector, fn {"img", attrs} ->
      attrs = List.keyreplace(attrs, "src", 0, {"src", img})
      {"img", attrs}
    end)
  end

  defp expand_image_src(ast, _context), do: ast

  defp expand_links(ast, %{"board_name" => board, "id" => card_id}) do
    Floki.traverse_and_update(ast, fn
      {"a", attrs, contents} ->
        href = List.keyfind(attrs, "href", 0) |> snd()

        case maybe_get_card(href, board) do
          {:ok, card} ->
            attrs = List.keyreplace(attrs, "href", 0, {"href", card.link_path})

            attrs =
              if card.id == card_id do
                [{"class", "card-link current-card"} | attrs]
              else
                [{"class", "card-link"} | attrs]
              end

            {"a", attrs, contents}

          :nocard ->
            {"span", [], contents}

          :external ->
            {"a", attrs, contents}
        end

      other ->
        other
    end)
  end

  def maybe_get_card(href, board) do
    card_id = {board, String.trim_trailing(href, ".md")}

    if card_href?(href) do
      case Storage.get(card_id) do
        nil -> :nocard
        data -> {:ok, data}
      end
    else
      :external
    end
  end

  defp card_href?(href) do
    String.ends_with?(href, ".md") && is_nil(URI.parse(href).scheme)
  end
end
