defmodule Tabula.Board do
  defmodule Card do
    @enforce_keys [:title, :path]
    defstruct [:title, :path]
  end

  defmodule List do
    @enforce_keys [:name]
    defstruct name: nil, path: nil, cards: []
  end

  @enforce_keys [:name, :dir]
  defstruct name: nil, dir: nil, lists: []

  def build(data, dir) do
    %__MODULE__{
      name: data["board"],
      dir: dir,
      lists:
        for list <- data["lists"] do
          list_path = list["path"] || safe_path(list["name"])

          %List{
            name: list["name"],
            path: list_path,
            cards:
              for card <- list["cards"] do
                %Card{
                  title: card,
                  path:
                    Path.join([
                      safe_path(data["board"]),
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
