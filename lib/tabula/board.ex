defmodule Tabula.Board do
  @moduledoc "Representation of an board: list of cards."

  alias Tabula.Storage

  @release_dir Application.compile_env(:tabula, :release_dir)
  def build(dir) do
    data = read_yaml(dir)
    board_name = data["board"]
    board_path = data["path"] || safe_path(board_name)

    board_icon =
      case data["icon"] do
        nil -> nil
        img -> Path.join("/assets/images", img)
      end

    board_img_dir = Path.join(["/assets/images/", board_path])

    %{
      title: board_name,
      base_path: board_path,
      target_dir: Path.join([@release_dir, board_path]),
      source_path: Path.join([dir, "_items.yml"]),
      assets_source_path: Path.join([dir, "_images/"]),
      assets_target_path: Path.join([@release_dir, board_img_dir]),
      index_page_path: Path.join([@release_dir, board_path, "index.html"]),
      icon_path: board_icon,
      lists:
        for list <- List.wrap(data["lists"]) do
          list_path = list["path"] || safe_path(list["name"])

          %{
            name: list["name"],
            base_path: list_path,
            target_path: Path.join([@release_dir, board_path, list_path]),
            cards:
              for card_name <- List.wrap(list["cards"]) do
                source = Path.join([dir, list_path, card_name <> ".md"])
                link = Path.join(["/", board_path, list_path, safe_path(card_name) <> ".html"])
                target = Path.join([@release_dir, link])

                %{
                  id: {board_name, card_name},
                  title: card_name,
                  subtitle: nil,
                  source_path: source,
                  target_path: target,
                  link_path: link,
                  image_path: nil,
                  default_image_path: board_icon,
                  image_base_dir: board_img_dir,
                  board_name: board_name,
                  board_page_url: board_page_url(board_name),
                  list_name: list["name"],
                  list_page_url: list_page_url(board_name, list),
                  tags: [],
                  rating: nil,
                  exists: false
                }
                |> tap(&Storage.put(&1))
              end
          }
        end
    }
  end

  defp read_yaml(board_dir) do
    yml_path = Path.join([board_dir, "_items.yml"])

    with {:ok, yml} <- File.read(yml_path),
         {:ok, data} <- YamlElixir.read_from_string(yml) do
      data
    end
  end

  @ignore_chars [":", ",", "."]
  @replace_chars [" • ", " - ", " "]

  def safe_path(path) do
    path
    |> String.replace(@ignore_chars, "")
    |> String.replace(@replace_chars, "-")
    |> String.downcase()
  end

  def board_page_url(board_name) do
    Path.join(["/", safe_path(board_name), "/index.html"])
  end

  def list_page_url(board_name, list) do
    list_id = list["path"] || safe_path(list["name"])
    Path.join(["/", safe_path(board_name), "/index.html##{list_id}"])
  end
end
