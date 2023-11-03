defmodule Tabula.Import.MarkdownGenerator do
  @moduledoc ~S"""
  Generate Markdown for a card.
  """

  def generate(data) do
    [
      metadata(data),
      header(data),
      card_image(data),
      description(data),
      checklists(data)
    ]
  end

  defp header(%{name: name}), do: ["# ", name, "\n\n"]

  defp description(%{description: desc}), do: [desc, "\n\n"]

  defp card_image(%{name: name}) do
    ["![image](../_images/#{safe_path(name)}.jpeg)", "\n\n"]
  end

  defp checklists(%{checklists: []}), do: []

  defp checklists(%{checklists: lists}) do
    formated_lists = for list <- lists, do: checklist(list)

    ["## Checklists\n\n", formated_lists]
  end

  defp checklist(%{name: list_name, items: items}) do
    list_items =
      for {text, state} <- items,
          do: [
            if(state, do: "- [x] ", else: "- [ ] "),
            text,
            "\n"
          ]

    ["### #{list_name}\n\n", list_items]
  end

  defp metadata(data) do
    [
      "---\n",
      timestamps(data),
      tags(data),
      "---\n"
    ]
  end

  defp tags(%{labels: tags}), do: ["tags: ", Enum.join(tags, ", "), "\n"]

  defp timestamps(_data) do
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()

    [
      "created_at: ",
      timestamp,
      "\n",
      "updated_at: ",
      timestamp,
      "\n"
    ]
  end

  defp safe_path(path) when is_binary(path) do
    path |> String.replace([":"], "") |> String.replace("/", " - ")
  end
end
