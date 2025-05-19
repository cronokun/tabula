defmodule Tabula.Card do
  @moduledoc "Conver card from markdown to HTML"

  alias Tabula.Markdown.{Parser, PostProcessor, Renderer}
  alias Tabula.{Storage, Utils}

  def convert(card) do
    case File.read(card.source_path) do
      {:ok, content} ->
        {context, markdown} = maybe_parse_front_matter(content)
        ast = Parser.parse(markdown)
        context = process_context(context, card, ast)

        PostProcessor.modify_ast(ast, context)
        |> Renderer.to_html()

      {:error, _} ->
        :skipped
    end
  end

  @front_matter_spliter ~r/\n?---\n/

  defp maybe_parse_front_matter(content) do
    case String.split(content, @front_matter_spliter, trim: true) do
      [markdown] ->
        {%{}, markdown}

      [yaml, markdown] ->
        {:ok, context} = YamlElixir.read_from_string(yaml)
        {context, markdown}
    end
  end

  defp process_context(context, card, ast) do
    context
    |> Map.put("list_name", card.list_name)
    |> Map.put("source", card.source_path)
    |> process_tags()
    |> set_title_from_header(ast)
    |> set_image_path(ast, card)
    |> tap(&Storage.put(card, &1))
  end

  defp process_tags(context) do
    tags =
      case context["tags"] do
        nil -> nil
        tags -> String.split(tags, ", ")
      end

    due_date =
      case context["due_date"] do
        nil -> nil
        date -> Utils.rel_due_date(date)
      end

    tags = List.wrap(tags) ++ List.wrap(due_date)

    Map.put(context, "tags", tags)
  end

  defp set_title_from_header(context, ast) do
    title = Floki.find(ast, "h1") |> Floki.text()

    subtitle =
      case Floki.find(ast, "h1 + h2") |> Floki.text() do
        "" -> nil
        subtitle -> subtitle
      end

    context
    |> Map.put("title", title)
    |> Map.put("subtitle", subtitle)
  end

  @cover_image_selector "h1 ~ p img"

  defp set_image_path(context, ast, card) do
    img =
      ast
      |> Floki.find(@cover_image_selector)
      |> Floki.attribute("src")
      |> case do
        [] -> nil
        [img] -> Path.join([card.image_base_dir, img])
      end

    Map.put(context, "image_path", img)
  end
end
