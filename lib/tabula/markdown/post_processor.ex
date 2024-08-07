defmodule Tabula.Markdown.PostProcessor do
  @moduledoc """
  Do some AST post-processing:

  1. Wrap card's AST info HTML document;
  2. Insert tags;
  3. Expand image path.
  """

  def modify_ast(ast, context) do
    ast
    |> into_html_layout(context)
    |> insert_list_name(context)
    |> insert_tags(context)
    |> expand_image_src(context)
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
            {"link", [{"rel", "stylesheet"}, {"href", "/assets/css/card.css"}], []},
            {"title", [], [context["title"]]}
          ]},
         {"body", [], inner_ast}
       ]}
    ]
  end

  defp insert_list_name(ast, %{"list_name" => name}) do
    tag = {"span", [{"class", "list-tag"}], [name]}

    Floki.traverse_and_update(ast, fn
      {"h1", attrs, [inner]} -> {"h1", attrs, [tag, inner]}
      other -> other
    end)
  end

  defp insert_tags(ast, context) do
    tags_list = for(tag <- context["tags"], do: {"span", [], [tag]})
    tags_ast = {"p", [{"class", "tags"}], tags_list}

    Floki.traverse_and_update(ast, fn
      {"img", attrs, []} -> [{"img", attrs, []}, tags_ast]
      other -> other
    end)
  end

  @cover_image_selector "h1 ~ p img"

  defp expand_image_src(ast, %{"image_path" => nil}), do: ast

  defp expand_image_src(ast, %{"image_path" => img}) do
    Floki.find_and_update(ast, @cover_image_selector, fn {"img", attrs} ->
      attrs = List.keyreplace(attrs, "src", 0, {"src", img})
      {"img", attrs}
    end)
  end
end
