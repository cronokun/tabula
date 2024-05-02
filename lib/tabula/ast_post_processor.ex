defmodule Tabula.AstPostProcessor do
  @moduledoc """
  Post-process AST after markdown parser.
  """

  alias Tabula.Storage

  def modify_ast(ast, card, context) do
    context =
      context
      |> split_tags()
      |> set_title_from_header(ast)
      |> set_image_path(ast)

    Storage.add_card(card.name, context)

    ast
    |> insert_list_name(card.list)
    |> insert_tags(context)
    |> into_html_layout(context)
    |> expand_image_src(context["image_path"])
  end

  # ---- AST manipulation ----

  defp into_html_layout(inner_ast, context) do
    [
      {"doctype", [], []},
      {"html", [{"lang", "en"}],
       [
         {"head", [],
          [
            {"meta", [{"charset", "utf-8"}], []},
            {"link", [{"rel", "stylesheet"}, {"href", "../../assets/css/card.css"}], []},
            {"title", [], [context["title"]]}
          ]},
         {"body", [], inner_ast}
       ]}
    ]
  end

  defp insert_list_name(ast, list) do
    tag = {"span", [{"class", "list-tag"}], [list]}

    Floki.traverse_and_update(ast, fn
      {"h1", attrs, [inner]} -> {"h1", attrs, [tag, inner]}
      other -> other
    end)
  end

  defp insert_tags(ast, context) do
    tags_list = for(tag <- context["tags"], do: {"span", [], [tag]})
    tags_ast = {"p", [{"class", "tags"}], tags_list ++ due_date_tag(context)}

    Floki.traverse_and_update(ast, fn
      {"img", attrs, []} -> [{"img", attrs, []}, tags_ast]
      other -> other
    end)
  end

  # TODO: split into two functions: one for getting due date (maybe from context), other for generating AST.
  defp due_date_tag(%{"due_date" => due_date}) do
    date = Date.from_iso8601!(due_date)
    is_same_year = Date.utc_today().year == date.year

    text =
      if is_same_year do
        Calendar.strftime(date, "%b %d")
      else
        Calendar.strftime(date, "%b %d, %y")
      end

    [{"span", [], [text]}]
  end

  defp due_date_tag(_context), do: []

  @cover_image_selector "h1 + p > img"

  defp expand_image_src(ast, nil), do: ast

  defp expand_image_src(ast, img_path) do
    Floki.find_and_update(ast, @cover_image_selector, fn {"img", attrs} ->
      attrs = List.keyreplace(attrs, "src", 0, {"src", "../.." <> img_path})
      {"img", attrs}
    end)
  end

  # ---- Tags ----

  defp split_tags(context), do: Map.update(context, "tags", [], &String.split(&1, ", "))

  defp set_title_from_header(context, ast) do
    title = Enum.find_value(ast, "Untitled", fn {"h1", _, content} -> hd(content) end)
    Map.put(context, "title", title)
  end

  defp set_image_path(context, ast) do
    # FIXME: Need to wrap AST into a body tag to make `Floki.find` work.
    img =
      {"body", [], ast}
      |> Floki.find(@cover_image_selector)
      |> Floki.attribute("src")
      |> case do
        [] -> nil
        [img] -> "/assets/images/#{Storage.board_name()}/#{img}"
      end

    Map.put(context, "image_path", img)
  end
end
