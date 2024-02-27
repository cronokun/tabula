defmodule Tabula.IndexPageRendererTest do
  use ExUnit.Case

  alias Tabula.IndexPageRenderer
  alias Tabula.Board
  alias Tabula.Storage

  setup_all do
    setup_storage()
    board = test_board()
    html = IndexPageRenderer.to_html(board)
    ast = Floki.parse_document!(html)

    {:ok, %{ast: ast}}
  end

  test ".to_html/1 renders all lists", %{ast: ast} do
    section_headers =
      ast
      |> Floki.find("section h2")
      |> Enum.map(fn {"h2", _attrs, content} ->
        content |> hd() |> String.trim()
      end)

    assert section_headers == ["Wantlist", "Backlog", "Playing", "Finished", "Replay", "Dropped"]
  end

  test ".to_html/1 renders list header ancors", %{ast: ast} do
    section_ids =
      ast
      |> Floki.find("section h2")
      |> Enum.map(fn {"h2", attrs, _content} ->
        attrs |> List.keyfind("id", 0) |> elem(1)
      end)

    assert section_ids == ["wantlist", "backlog", "playing", "finished", "replay", "dropped"]
  end

  test ".to_html/1 renders all list items", %{ast: ast} do
    assert get_list_items(ast, "Wantlist") == ["Alan Wake 2"]

    assert get_list_items(ast, "Backlog") == [
             "The Last of Us Part I",
             "The Last of Us Part II Remastered"
           ]

    assert get_list_items(ast, "Playing") == ["Pathfinder: Kingmaker"]

    assert get_list_items(ast, "Finished") == [
             "Oxenfree II: Lost Signals",
             "Hogwarts Legacy",
             "Dead Space",
             "The Callisto Protocol"
           ]

    assert get_list_items(ast, "Dropped") == ["Baldur's Gate 3"]
    assert get_list_items(ast, "Replay") == []
  end

  test ".to_html/1 renders card tags", %{ast: ast} do
    assert get_card_tags(ast, "Alan Wake 2") == ["PS5", "18+"]
  end

  test ".to_html/1 renders list items count", %{ast: ast} do
    counts =
      Enum.map(
        ["Wantlist", "Backlog", "Playing", "Finished", "Replay", "Dropped"],
        fn section ->
          {
            section,
            Floki.find(ast, "section h2:fl-contains('#{section}') span.count") |> Floki.text()
          }
        end
      )

    assert counts == [
             {"Wantlist", "1 card"},
             {"Backlog", "2 cards"},
             {"Playing", "1 card"},
             {"Finished", "4 cards"},
             {"Replay", ""},
             {"Dropped", "1 card"}
           ]
  end

  defp get_list_items(ast, list_name) do
    ast
    |> Floki.find("section h2:fl-contains('#{list_name}') + ul li a")
    |> Enum.map(&Floki.text/1)
  end

  defp get_card_tags(ast, card_name) do
    ast
    |> Floki.find("li.card a:fl-contains('#{card_name}') + p.tags > span")
    |> Enum.map(&Floki.text/1)
  end

  defp test_board do
    Board.build(
      %{
        "board" => "Videogames",
        "lists" => [
          %{"cards" => ["Alan Wake 2"], "name" => "Wantlist", "path" => "wantlist"},
          %{
            "cards" => ["The Last of Us Part I", "The Last of Us Part II Remastered"],
            "name" => "Backlog",
            "path" => "backlog"
          },
          %{"cards" => ["Pathfinder Kingmaker"], "name" => "Playing", "path" => "playing"},
          %{
            "cards" => [
              "Oxenfree II: Lost Signals",
              "Hogwarts Legacy",
              "Dead Space",
              "The Callisto Protocol"
            ],
            "name" => "Finished",
            "path" => "finished"
          },
          %{"cards" => nil, "name" => "Replay", "path" => "replay"},
          %{"cards" => ["Baldur's Gate 3"], "name" => "Dropped", "path" => "dropped"}
        ]
      },
      "test"
    )
  end

  defp setup_storage do
    Storage.init("Test Board")

    Storage.add_card("Alan Wake 2", %{
      "title" => "Alan Wake 2",
      "image_path" => "alan-wake-2.jpg",
      "tags" => ["PS5", "18+"]
    })

    Storage.add_card("The Last of Us Part I", %{
      "title" => "The Last of Us Part I",
      "image_path" => "last-of-us-part1.jpg"
    })

    Storage.add_card("The Last of Us Part II Remastered", %{
      "title" => "The Last of Us Part II Remastered",
      "image_path" => "last-of-us-part2-remastered.jpg"
    })

    Storage.add_card("Pathfinder Kingmaker", %{
      "title" => "Pathfinder: Kingmaker",
      "image_path" => "pathfinder-kingmaker.jpg"
    })

    Storage.add_card("Oxenfree II Lost Signals", %{"title" => "Oxenfree II Lost Signals"})
    Storage.add_card("Dead Space", %{"title" => "Dead Space", "image_path" => "dead-space.jpg"})

    Storage.add_card("The Callisto Protocol", %{
      "title" => "The Callisto Protocol",
      "image_path" => "the-callisto-protocol.jpg"
    })

    Storage.add_card("Baldur's Gate 3", %{
      "title" => "Baldur's Gate 3",
      "image_path" => "baldurs-gate-3.jpg"
    })
  end
end
