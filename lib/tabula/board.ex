defmodule Tabula.Board.Card do
  @enforce_keys [:name, :source_path, :target_path]
  defstruct [:name, :source_path, :target_path]
end

defmodule Tabula.Board.List do
  @enforce_keys [:name]
  defstruct name: nil, path: nil, cards: []
end

defmodule Tabula.Board do
  @enforce_keys [:name, :dir, :index_path, :lists]
  defstruct name: nil, dir: nil, index_path: nil, lists: []

  alias Tabula.Board.Card
  alias Tabula.Board.List, as: BList

  # FIXME: this is duplicated; move to config!
  @release_dir Path.expand("release")

  def build(data, dir) do
    %__MODULE__{
      name: data["board"],
      dir: dir,
      index_path: Path.join([@release_dir, data["board"], "index.html"]),
      lists:
        for list <- List.wrap(data["lists"]) do
          list_path = list["path"] || safe_path(list["name"])

          %BList{
            name: list["name"],
            path: list_path,
            cards:
              for card <- List.wrap(list["cards"]) do
                path = Path.join([list_path, safe_path(card)])

                %Card{
                  name: card,
                  source_path: Path.expand("#{dir}/#{path}.md"),
                  target_path: Path.expand("#{@release_dir}/#{data["board"]}/#{path}.html")
                }
              end
          }
        end
    }
  end

  defp safe_path(name) when is_binary(name) do
    name |> String.replace([":"], "") |> String.replace("/", " - ")
  end
end
