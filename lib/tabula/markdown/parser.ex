defmodule Tabula.Markdown.Parser do
  @moduledoc ~S"""
  Parse Markdown, process and convert to HTML.
  """

  def parse(content) when is_binary(content) do
    content
    |> parse_markdown()
    |> Enum.reduce([], fn block, acc -> [_parse(block) | acc] end)
    |> Enum.reverse()
  end

  defp parse_markdown(content) do
    {:ok, ast, _} = Earmark.Parser.as_ast(content)
    ast
  end

  defp _parse({"ul", attrs, content, meta}) do
    parsed_content =
      content
      |> Enum.reduce([], fn li, acc -> [_parse_li(li) | acc] end)
      |> Enum.reverse()

    {"ul", attrs, parsed_content, meta}
  end

  defp _parse(block), do: block

  @checked_checkbox {
    "input",
    [{"checked", ""}, {"disabled", ""}, {"type", "checkbox"}],
    [],
    %{verbatium: true}
  }

  @unchecked_checkbox {
    "input",
    [{"disabled", ""}, {"type", "checkbox"}],
    [],
    %{verbatium: true}
  }

  defp _parse_li({"li", attrs, ["[ ] " <> content], meta}) when is_binary(content) do
    {"li", attrs, [@unchecked_checkbox, " " <> content], meta}
  end

  defp _parse_li({"li", attrs, ["[x] " <> content], meta}) when is_binary(content) do
    {"li", attrs, [@checked_checkbox, " " <> content], meta}
  end

  defp _parse_li({"li", attrs, ["[ ] " | content], meta}) do
    {"li", attrs, [@unchecked_checkbox, content], meta}
  end

  defp _parse_li({"li", attrs, ["[x] " | content], meta}) do
    {"li", attrs, [@checked_checkbox, content], meta}
  end

  defp _parse_li(li), do: li
end
