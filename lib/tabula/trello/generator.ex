defmodule Tabula.Trello.Generator do
  @moduledoc ~S"""
  Generate Markdown for a card.
  """

  def to_markdown(data) do
    [
      metadata(data),
      Enum.join(
        [
          header(data),
          card_image(data),
          description(data),
          checklists(data)
        ],
        "\n\n"
      )
    ]
  end

  defp header(%{title: title}), do: ["# #{title}"]

  defp description(%{description: desc}) do
    description =
      desc
      |> String.replace(~r/\*\*(.+):\*\*/, "\\1::")
      |> String.replace("Release Date::", "Release::")

    [description]
  end

  defp card_image(%{name: name}) do
    path =
      name
      |> String.replace(~w[: / ' ’ . , ( ) +], "")
      |> String.downcase()
      |> String.replace(~r/\s+/, "-")

    ["![image](#{path}.jpeg)"]
  end

  defp checklists(%{checklists: lists}), do: Enum.map(lists, &render_checklist/1)

  defp render_checklist(%{name: list_name, items: items}) do
    list_items =
      for {text, state} <- items,
          do: [
            if(state, do: "- [x] ", else: "- [ ] "),
            text,
            "\n"
          ]

    ["## #{list_name}\n\n", list_items]
  end

  defp metadata(data) do
    [
      "---\n",
      timestamps(data),
      tags(data),
      "---\n"
    ]
  end

  defp tags(%{labels: []}), do: []
  defp tags(%{labels: tags}), do: ["tags: ", Enum.join(tags, ", "), "\n"]

  defp timestamps(data) do
    [
      "created_at: ",
      format_timestamp(data.created_at),
      "\n",
      "updated_at: ",
      format_timestamp(data.updated_at),
      "\n"
    ]
  end

  defp format_timestamp(timestamp), do: Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S")
end
