defmodule Tabula.Board.Card do
  @enforce_keys [:board, :name, :list, :source_path, :target_path]
  defstruct [:board, :name, :subtitle, :list, :source_path, :target_path]
end

defmodule Tabula.Board.List do
  @enforce_keys [:name]
  defstruct name: nil, path: nil, cards: []
end

defmodule Tabula.Board do
  @enforce_keys [:name, :dir, :index_path, :lists]
  defstruct name: nil, dir: nil, index_path: nil, lists: []

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

          %Tabula.Board.List{
            name: list["name"],
            path: list_path,
            cards:
              for card <- List.wrap(list["cards"]) do
                path = Path.join([list_path, safe_path(card)])

                %Tabula.Board.Card{
                  name: card,
                  list: list["name"],
                  board: data["board"],
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
