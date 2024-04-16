defmodule Tabula.Markdown.Parser do
  @moduledoc """
  Parse Markdown, process and convert to HTML.
  """

  def parse(content) when is_binary(content) do
    content
    |> parse_markdown()
    |> parse_ast()
  end

  defp parse_markdown(content) do
    {:ok, ast, _} = EarmarkParser.as_ast(content)
    ast
  end

  defp parse_ast(ast) do
    ast
    |> remove_meta()
    |> Enum.reduce([], fn block, acc -> [parse_block(block) | acc] end)
    |> Enum.reverse()
  end

  defp parse_block({"ul", attrs, content}) do
    {lis, res} =
      Enum.reduce(content, {[], nil}, fn li, {acc, res} ->
        {li, r} = _parse_li(li)
        {[li | acc], res || r}
      end)

    attrs = if res == :checklist, do: [{"class", "checklist"} | attrs], else: attrs

    {"ul", attrs, Enum.reverse(lis)}
  end

  defp parse_block({"p", attrs, content} = block) do
    case _parse_description_list(content) do
      {:ok, list} -> {"dl", attrs, list}
      _ -> block
    end
  end

  defp parse_block(block), do: block

  # --- Checklist ---

  @checked_checkbox {
    "input",
    [{"checked", ""}, {"disabled", ""}, {"type", "checkbox"}],
    []
  }

  @unchecked_checkbox {
    "input",
    [{"disabled", ""}, {"type", "checkbox"}],
    []
  }

  defp _parse_li({"li", attrs, ["[ ] " <> content]}) when is_binary(content) do
    {{"li", attrs, [@unchecked_checkbox, " " <> content]}, :checklist}
  end

  defp _parse_li({"li", attrs, ["[x] " <> content]}) when is_binary(content) do
    {{"li", attrs, [@checked_checkbox, " " <> content]}, :checklist}
  end

  defp _parse_li({"li", attrs, ["[ ] " | content]}) do
    {{"li", attrs, [@unchecked_checkbox, content]}, :checklist}
  end

  defp _parse_li({"li", attrs, ["[x] " | content]}) do
    {{"li", attrs, [@checked_checkbox, content]}, :checklist}
  end

  defp _parse_li(li), do: {li, nil}

  # --- Description list ---

  defp _parse_description_list(content) when is_list(content) do
    if definition_list?(content) do
      list =
        content
        |> Enum.map(fn i ->
          if is_binary(i) do
            String.split(i, "\n")
          else
            i
          end
        end)
        |> List.flatten()

      {:ok, split_list_to_dt_dd(list)}
    else
      :nope
    end
  end

  @dl_regex ~r/\b::\s+/

  defp split_list_to_dt_dd(list, acc \\ [], dacc \\ [])

  defp split_list_to_dt_dd([], acc, dacc) do
    Enum.reverse([{"dd", [], Enum.reverse(dacc)} | acc])
  end

  defp split_list_to_dt_dd([head | tail], acc, dacc) when is_tuple(head) do
    split_list_to_dt_dd(tail, acc, [head | dacc])
  end

  defp split_list_to_dt_dd([head | tail], acc, dacc) when is_binary(head) do
    {acc, dacc} =
      head
      |> String.split(@dl_regex)
      |> process_dt_dd(acc, dacc)

    split_list_to_dt_dd(tail, acc, dacc)
  end

  defp process_dt_dd([desc], acc, dacc), do: {acc, [desc | dacc]}

  defp process_dt_dd([term, ""], acc, []) do
    dt = {"dt", [], [term]}
    {[dt | acc], []}
  end

  defp process_dt_dd([term, ""], acc, dacc) do
    dd = {"dd", [], Enum.reverse(dacc)}
    dt = {"dt", [], [term]}
    {[dt | [dd | acc]], []}
  end

  defp process_dt_dd([term, desc], acc, []) do
    dt = {"dt", [], [term]}
    {[dt | acc], [desc]}
  end

  defp process_dt_dd([term, desc], acc, dacc) do
    dd = {"dd", [], Enum.reverse(dacc)}
    dt = {"dt", [], [term]}
    {[dt | [dd | acc]], [desc]}
  end

  defp definition_list?(content) when is_list(content) do
    content |> Enum.filter(&is_binary/1) |> Enum.any?(&String.match?(&1, @dl_regex))
  end

  # --- Utils ---

  defp remove_meta(list, acc \\ [])
  defp remove_meta([], acc), do: Enum.reverse(acc)

  defp remove_meta([{tag, attrs, content, _meta} | rest], acc) do
    block = {tag, attrs, remove_meta(content, [])}
    remove_meta(rest, [block | acc])
  end

  defp remove_meta([block | rest], acc) do
    remove_meta(rest, [block | acc])
  end
end
