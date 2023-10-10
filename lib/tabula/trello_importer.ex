defmodule Tabula.TrelloImporter do
  @moduledoc ~S"""
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

  All positions (of lists, cards, checklists and checkitems) are big integers:
  17329, 33996, 51070, 68057, 85064, 101579, 118504, 135367, 151773, 169172, etc.
  """

  def parse(filepath) do
    filepath
    |> read_json()
    |> convert_to_map()
  end

  defp read_json(filepath) do
    filepath
    |> File.read!()
    |> Jason.decode!()
  end

  defp convert_to_map(json) do
    %{}
    |> put_in_top_level_data(json)
    |> put_in_lists(json)
  end

  defp put_in_top_level_data(board, json) do
    board
    |> Map.put(:name, json["name"])
  end

  defp put_in_lists(board, json) do
    lists =
      json["lists"]
      |> Enum.reject(&(&1["closed"] == true))
      |> Enum.sort_by(& &1["pos"])
      |> Enum.map(fn list -> get_list_data(json, list["name"], list["id"]) end)

    Map.put(board, :lists, lists)
  end

  defp get_list_data(json, list_name, list_id) do
    %{
      name: list_name,
      cards: get_list_cards(json, list_id)
    }
  end

  defp get_list_cards(json, list_id) do
    json["cards"]
    |> Enum.filter(&(&1["idList"] == list_id and &1["closed"] == false))
    |> Enum.sort_by(& &1["pos"])
    |> Enum.map(
      &%{
        name: &1["name"],
        description: &1["desc"],
        labels: get_card_labels(&1),
        checklists: get_card_checklists(json, &1["idChecklists"])
      }
    )
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
end
