defmodule Tabula.Board.Card do
  @enforce_keys [:title, :path]
  defstruct [:title, :path]
end

defmodule Tabula.Board.List do
  @enforce_keys [:name]
  defstruct name: nil, path: nil, cards: []
end

defmodule Tabula.Board do
  @enforce_keys [:name, :dir]
  defstruct name: nil, dir: nil, lists: []

  alias Tabula.Board.Card
  alias Tabula.Board.List, as: BList

  def build(data, dir) do
    %__MODULE__{
      name: data["board"],
      dir: dir,
      lists:
        for list <- List.wrap(data["lists"]) do
          list_path = list["path"] || safe_path(list["name"])

          %BList{
            name: list["name"],
            path: list_path,
            cards:
              for card <- List.wrap(list["cards"]) do
                %Card{
                  title: card,
                  path:
                    Path.join([
                      list_path,
                      safe_path(card)
                    ])
                }
              end
          }
        end
    }
  end

  defp safe_path(title) when is_binary(title) do
    title |> String.replace([":"], "") |> String.replace("/", " - ")
  end
end
