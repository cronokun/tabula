defmodule Tabula.Convert do
  @moduledoc ~S"""
  Create HTML files from Markdown cards.
  """

  alias Tabula.Board.Card
  alias Tabula.Markdown.Parser
  alias Tabula.Markdown.Renderer
  alias Tabula.Storage

  def convert_file(card) when is_struct(card, Card) do
    case File.read(card.source_path) do
      {:ok, content} ->
        {markdown, context} = maybe_parse_front_matter(content)

        html =
          markdown
          |> Parser.parse()
          |> post_process_ast(card, context)
          |> Renderer.to_html()

        File.write!(card.target_path, html)

      {:error, _} ->
        :skipped
    end
  end

  @front_matter_spliter ~r/\n?---\n/

  defp maybe_parse_front_matter(content) do
    case String.split(content, @front_matter_spliter, trim: true) do
      [markdown] ->
        {markdown, %{}}

      [yaml, markdown] ->
        {:ok, front_matter} = YamlElixir.read_from_string(yaml)
        {markdown, front_matter}
    end
  end

  defp post_process_ast(ast, card, context) do
    context =
      context
      |> split_tags()
      |> set_title_from_header(ast)
      |> set_image_path(ast)

    Storage.add_card(card.name, context)

    ast
    |> insert_tags(context)
    |> into_html_layout(context)
    |> process_images_src(context["image_path"])
  end

  defp set_title_from_header(context, ast) do
    title = Enum.find_value(ast, "Untitled", fn {"h1", _, content} -> hd(content) end)
    Map.put(context, "title", title)
  end

  @cover_image_selector "h1 + p > img"

  defp set_image_path(context, ast) do
    # Need to wrap AST into a body tag to make `Floki.find` work.
    [{"img", attrs, []}] = Floki.find({"body", [], ast}, @cover_image_selector)
    src = List.keyfind(attrs, "src", 0) |> elem(1)
    Map.put(context, "image_path", "/assets/images/#{Storage.board_name()}/#{src}")
  end

  defp split_tags(context), do: Map.update(context, "tags", [], &String.split(&1, ", "))

  defp insert_tags(ast, context) do
    tags_list = for(tag <- context["tags"], do: {"span", [], [tag]})
    tags_ast = {"p", [{"class", "tags"}], tags_list ++ due_date_tag(context)}

    Floki.traverse_and_update(ast, fn
      {"img", attrs, []} -> [{"img", attrs, []}, tags_ast]
      other -> other
    end)
  end

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

  defp process_images_src(ast, img_path) do
    Floki.find_and_update(ast, @cover_image_selector, fn {"img", attrs} ->
      attrs = List.keyreplace(attrs, "src", 0, {"src", "../.." <> img_path})
      {"img", attrs}
    end)
  end

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
end
