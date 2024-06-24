defmodule Tabula.BuildIndex do
  @moduledoc "Build and render a global index page"

  alias Tabula.Markdown.Renderer

  @doc "Build and render a global index page"
  def run do
    File.cp!("assets/css/index.css", "release/assets/css/index.css")

    Path.wildcard("priv/boards/*/_items.yml")
    |> Enum.map(&read_board_data(&1))
    |> generate_ast()
    |> write_to_html()
  end

  defp read_board_data(file) do
    with {:ok, yml} <- File.read(file),
         {:ok, data} <- YamlElixir.read_from_string(yml) do
      lists =
        Enum.map(data["lists"], fn list ->
          {list["name"], list_path(list, data["board"]), cards_count(list)}
        end)

      %{
        name: data["board"],
        lists: lists
      }
    end
  end

  defp cards_count(%{"cards" => nil}), do: 0
  defp cards_count(%{"cards" => cards}), do: length(cards)

  defp list_path(list, board) do
    path = list["path"] || safe_path(list["name"])
    Path.expand(["release/", board, "/index.html##{path}"])
  end

  # FIXME: duplicate, move to utils module!
  defp safe_path(name) when is_binary(name) do
    name |> String.replace([":"], "") |> String.replace("/", " - ")
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
             {"link", [{"rel", "stylesheet"}, {"href", "../release/assets/css/index.css"}], []},
             {"title", [], ["Boards"]}
           ]},
          {"body", [],
           [
             {"h1", [], ["Boards"]},
             for(board <- data, do: render_board(board))
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

  defp list_href({name, path, _count}), do: {"a", [{"href", path}], [name]}

  def write_to_html(ast) do
    html = Renderer.to_html(ast)
    File.write!("release/index.html", html)
  end
end
