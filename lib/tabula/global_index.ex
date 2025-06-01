defmodule Tabula.GlobalIndex do
  @moduledoc "Creates a landing page with links to all boards."

  alias Tabula.Board
  alias Tabula.Markdown.Renderer

  @boards_dir Application.compile_env(:tabula, :base_boards_dir)
  @release_dir Application.compile_env(:tabula, :release_dir)

  def create do
    html =
      get_boards_data()
      |> generate_ast()
      |> Renderer.to_html()

    File.write!(Path.join([@release_dir, "index.html"]), html)
  end

  defp get_boards_data do
    for board_file <- Path.wildcard(@boards_dir <> "*/_items.yml") do
      with {:ok, yml} <- File.read(board_file),
           {:ok, data} <- YamlElixir.read_from_string(yml) do
        lists =
          for list <- data["lists"] do
            {list["name"], list_path(list, data["board"]), cards_count(list)}
          end

        %{
          name: data["board"],
          lists: lists
        }
      end
    end
  end

  defp cards_count(%{"cards" => nil}), do: 0
  defp cards_count(%{"cards" => cards}), do: length(cards)

  # FIXME: replace this with `Board.build/1` or `Board.build_lists/1`?
  defp list_path(list, board) do
    board_path = Board.safe_path(board)
    list_id = list["path"] || Board.safe_path(list["name"])
    Path.join([board_path, "/index.html##{list_id}"])
  end

  # ----  AST and HTML  --------

  defp generate_ast(data) do
    [
      {"doctype", [], []},
      {
        "html",
        [{"lang", "en"}],
        [
          {"head", [],
           [
             {"meta", [{"charset", "utf-8"}], []},
             {"link", [{"rel", "stylesheet"}, {"href", "/assets/css/index.css"}], []},
             {"title", [], ["Boards"]}
           ]},
          {"body", [],
           [
             {"h1", [], ["Boards"]},
             {"main", [], for(board <- data, do: render_board(board))}
           ]}
        ]
      }
    ]
  end

  defp render_board(%{name: board, lists: lists}) do
    {
      "section",
      [],
      [
        {"h2", [], [board]},
        {"a", [{"href", board_href(board)}], ["( board )"]},
        {"ul", [],
         [
           for list <- lists do
             {"li", [], [list_href(list), list_cards_counter(list)]}
           end
         ]}
      ]
    }
  end

  defp list_cards_counter({_name, _path, count}),
    do: {"span", [{"class", "count"}], [to_string(count)]}

  defp board_href(board), do: Path.join([Board.safe_path(board), "/index.html"])

  defp list_href({name, path, _count}), do: {"a", [{"href", path}], [name]}
end
