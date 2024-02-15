defmodule Tabula.Convert do
  @moduledoc ~S"""
  Create HTML files from Markdown cards.
  """

  alias Tabula.Markdown.Parser
  alias Tabula.Markdown.Renderer
  alias Tabula.Storage

  def run(paths) when is_list(paths) do
    for filepath <- paths do
      IO.puts("converting card: #{filepath}")
      convert_file(filepath)
    end
  end

  def convert_file(input_path) do
    output_path = String.replace(input_path, ~r/\.(md|markdown)$/, ".html")
    convert_file(input_path, output_path)
  end

  def convert_file(input_path, output_path) do
    case File.read(input_path) do
      {:ok, content} ->
        {markdown, context} = maybe_parse_front_matter(content)

        html =
          markdown
          |> Parser.parse()
          |> post_process_ast(context)
          |> Renderer.to_html()

        File.write!(output_path, html)

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

  defp post_process_ast(ast, context) do
    context =
      context
      |> split_tags()
      |> set_title_from_header(ast)
      |> set_image_path(ast)

    Storage.add_card(context)

    ast
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
    Map.put(context, "image_path", "../../assets/images/#{Storage.board_name()}/#{src}")
  end

  defp split_tags(context), do: Map.update(context, "tags", "", &String.split(&1, ", "))

  defp into_html_layout(inner_ast, context) do
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
  end

  defp process_images_src(ast, img_path) do
    Floki.find_and_update(ast, @cover_image_selector, fn {"img", attrs} ->
      attrs = List.keyreplace(attrs, "src", 0, {"src", img_path})
      {"img", attrs}
    end)
  end
end
