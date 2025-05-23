defmodule Tabula.Trello.JsonParser do
  @moduledoc """
  Extract data from JSON files exported from Trello.

  ### JSON files from Trello

  Top level-keys:

  - name:       name of the board

  - cards:      list of cards
    - id      card Id
    - idBoard related board ID
    - idList  related list ID
    - name    card's name
    - desc    card's description (markdown)
    - pos     card's position in the list?
    - attachments: list of attachments
        - name      attachment's name (i.e. "cover.jpeg")
        - mimeType  "image/jpeg"
        - pos
        - url       attachment's URL
    - labels: list of labels applied to card
        - name    label name
        - color   label color
    - idChecklists  list of related checklist's IDs
    - idLabels      list of related label's IDs (why?)

  - checklists: list of all checklists:
    - id          checklist's ID
    - idCard      related card's ID
    - name        name of the checklist, like "Trophies"
    - pos         position of checklist
    - checkItems: list of items in the checklist:
        - id      item's ID
        - name    item's name
        - pos     position of checklist item
        - state   complete / incomplete

  - labels: list of all labels:
    - id      label's ID
    - name    label's name, like "coming soon", "PS5", "100%", etc
    - color   label's color name (don't need it?)

  - lists: list of board's lists:
    - id      list ID
    - name    list name ("Wantlist", "Playing Now", etc)
    - pos     position of the list

  - actions:    list of all board/card actions
    - date    when action occured
    - type    action type, we are interested in "createCard" and "updateCard"
    - data
      - card
        - id    the card id

  All positions (of lists, cards, checklists and checkitems) are big integers:
  17329, 33996, 51070, 68057, 85064, 101579, 118504, 135367, 151773, 169172, etc.
  """

  def parse(file) do
    {:ok, json} = file |> File.read!() |> JSON.decode()

    data = %{
      name: json["name"],
      lists: extract_lists(json)
    }

    {:ok, data}
  end

  defp extract_lists(json) do
    json["lists"]
    |> Enum.reject(&(&1["closed"] == true))
    |> Enum.sort_by(& &1["pos"])
    |> Enum.map(fn list ->
      %{
        name: list["name"],
        cards: extract_list_cards(json, list["id"])
      }
    end)
  end

  defp extract_list_cards(json, list_id) do
    json["cards"]
    |> Enum.filter(&(&1["idList"] == list_id and &1["closed"] == false))
    |> Enum.sort_by(& &1["pos"])
    |> Enum.map(fn card ->
      %{
        name: title_to_name(card["name"]),
        title: card["name"],
        description: card["desc"],
        created_at: get_created_at(json, card["id"], card["dateLastActivity"]),
        updated_at: get_updated_at(json, card["id"], card["dateLastActivity"]),
        labels: get_card_labels(card),
        checklists: get_card_checklists(json, card["idChecklists"])
      }
    end)
  end

  defp get_card_labels(card) do
    Enum.map(card["labels"], & &1["name"])
  end

  defp get_card_checklists(json, checklist_ids) do
    checklist_ids
    |> Enum.map(fn id ->
      Enum.find(json["checklists"], &(&1["id"] == id))
    end)
    |> Enum.map(fn cjson ->
      %{
        name: cjson["name"],
        items: extract_checklist_items(cjson)
      }
    end)
  end

  defp extract_checklist_items(cjson) do
    cjson["checkItems"]
    |> Enum.sort_by(& &1["pos"])
    |> Enum.map(&{&1["name"], &1["state"] == "complete"})
  end

  defp get_created_at(json, card_id, fallback) do
    {:ok, timestamp, _} =
      json["actions"]
      |> Enum.find(%{}, &find_by_id_and_type(&1, card_id, ["createCard"]))
      |> Map.get("date", fallback)
      |> DateTime.from_iso8601()

    timestamp
  end

  defp get_updated_at(json, card_id, fallback) do
    action =
      json["actions"]
      |> Enum.filter(
        &find_by_id_and_type(&1, card_id, ["updateCard", "updateCheckItemStateOnCard"])
      )
      |> Enum.sort_by(& &1["date"], :desc)
      |> case do
        [] -> %{}
        list -> hd(list)
      end

    {:ok, timestamp, _} = Map.get(action, "date", fallback) |> DateTime.from_iso8601()

    timestamp
  end

  defp find_by_id_and_type(action, id, types),
    do: action["data"]["card"]["id"] == id and action["type"] in types

  defp title_to_name(title) do
    title
    |> String.replace(~w[: / ' ’ . , +], "")
    |> String.replace(~r/ \(\d{4}(.+)?\)$/, "")
  end
end
