defmodule Tabula.Markdown.PostProcessorTest do
  use ExUnit.Case, async: true

  alias Tabula.Storage

  import Tabula.Markdown.PostProcessor, only: [modify_ast: 2]

  @context %{
    "board_name" => "Test Board",
    "id" => "card1",
    "image_path" => "/assets/images/test_board/the-phoenician-scheme-2025.jpg",
    "list_name" => "Test List",
    "source" => "list/card1.md",
    "title" => "The Phoenician Scheme (2025)",
    "tags" => []
  }

  describe "modify_ast/2" do
    test "wraps AST into HTML layout" do
      ast = [
        {"h1", [], ["The Phoenician Scheme"]},
        {"p", [],
         [
           "Wealthy businessman Zsa-zsa Korda appoints his only daughter, a nun, as sole heir to his estate. As Korda embarks on a new enterprise, they soon become the target of scheming tycoons, foreign terrorists and determined assassins."
         ]}
      ]

      assert [
               {"doctype", [], []},
               {"html", [{"lang", "en"}],
                [
                  {"head", [],
                   [
                     {"meta", [{"charset", "utf-8"}], []},
                     {"link", [{"rel", "stylesheet"}, {"href", "/assets/css/card.css"}], []},
                     {"title", [], ["The Phoenician Scheme (2025)"]}
                   ]},
                  {"body", [],
                   [
                     _rest,
                     {"h1", [], ["The Phoenician Scheme"]},
                     {"p", [],
                      [
                        "Wealthy businessman Zsa-zsa Korda appoints his only daughter, a nun, as sole heir to his estate. As Korda embarks on a new enterprise, they soon become the target of scheming tycoons, foreign terrorists and determined assassins."
                      ]}
                   ]}
                ]}
             ] = modify_ast(ast, @context)
    end

    test "expands cover image SRC attribute" do
      ast = [
        {"h1", [], ["The Phoenician Scheme"]},
        {"p", [],
         [
           {"img", [{"src", "the-phoenician-scheme-2025.jpg"}], []}
         ]},
        {"p", [],
         [
           "Wealthy businessman Zsa-zsa Korda appoints his only daughter, a nun, as sole heir to his estate. As Korda embarks on a new enterprise, they soon become the target of scheming tycoons, foreign terrorists and determined assassins."
         ]},
        {"p", [],
         [
           {"img", [{"src", "https://m.media-amazon.com/images/M/screenshot1.jpg"}], []}
         ]}
      ]

      [url1, url2] =
        ast |> modify_ast(@context) |> Floki.find("h1 ~ p > img") |> Floki.attribute("src")

      assert url1 == "/assets/images/test_board/the-phoenician-scheme-2025.jpg"
      assert url2 == "https://m.media-amazon.com/images/M/screenshot1.jpg"
    end

    test "expands HREF attribute for links to other cards" do
      ast = [
        {"p", [],
         [
           {"a", [{"href", "https://imdb.com"}], ["Link to IMDB"]},
           {"a", [{"href", "Card 2.md"}], ["Link to another card"]},
           {"a", [{"href", "Card 3.md"}], ["Link to non-existent card"]}
         ]}
      ]

      Storage.put(%{
        id: {"Test Board", "Card 2"},
        link_path: "/test-board/list/card-2.html"
      })

      assert [
               {"p", [],
                [
                  {"a", [{"href", "https://imdb.com"}], ["Link to IMDB"]},
                  {"a", [{"class", "card-link"}, {"href", "/test-board/list/card-2.html"}],
                   ["Link to another card"]},
                  {"span", [], ["Link to non-existent card"]}
                ]}
             ] = modify_ast(ast, @context) |> get_content()
    end

    test "adds pre-header section with edit link" do
      ast = [
        {"h1", [], ["The Dark Knight"]},
        {"p", [],
         [
           "When a menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman, James Gordon and Harvey Dent must work together to put an end to the madness."
         ]}
      ]

      context = %{
        "id" => "TheDarkKnight",
        "board_name" => "Movies",
        "list_name" => "Directed by Christopher Nolan",
        "image_path" => "/assets/images/movies/nolan/the-dark-knight-2008.jpg",
        "title" => "The Dark Knight (2008)",
        "source" => "Nolan/TheDarkKnight.md",
        "tags" => []
      }

      assert [
               {"div", [{"class", "pre-header"}],
                [
                  {"span", [{"class", "list-tag"}], ["Directed by Christopher Nolan"]},
                  {"a",
                   [
                     {"href", "mvim://open?url=file://Nolan/TheDarkKnight.md"},
                     {"class", "edit-btn"}
                   ], ["Edit card"]}
                ]},
               {"h1", _, _},
               {"p", _, _}
             ] = ast |> modify_ast(context) |> get_content()
    end

    test "adds card's tags section" do
      ast = [
        {"h1", [], ["The Dark Knight"]},
        {"p", [],
         [
           {"img", [{"href", "the-dark-knight-2008.jpg"}], []}
         ]},
        {"p", [],
         [
           "When a menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman, James Gordon and Harvey Dent must work together to put an end to the madness."
         ]}
      ]

      context = %{
        "id" => "TheDarkKnight",
        "board_name" => "Movies",
        "list_name" => "Directed by Christopher Nolan",
        "image_path" => "/assets/images/movies/nolan/the-dark-knight-2008.jpg",
        "title" => "The Dark Knight (2008)",
        "source" => "Nolan/TheDarkKnight.md",
        "tags" => ["Genre: Action", "Genre: Drama", "Genre: Triller"]
      }

      assert [
               {"div", [{"class", "pre-header"}], _},
               {"h1", _, _},
               {
                 "p",
                 [],
                 [
                   {"img", [{"href", "the-dark-knight-2008.jpg"}], []},
                   {"p", [{"class", "tags"}],
                    [
                      {"span", [], ["Genre: Action"]},
                      {"span", [], ["Genre: Drama"]},
                      {"span", [], ["Genre: Triller"]}
                    ]}
                 ]
               },
               {"p", _, _}
             ] = ast |> modify_ast(context) |> get_content()
    end
  end

  defp get_content(ast) do
    [
      {"doctype", [], []},
      {"html", _,
       [
         {"head", _, _},
         {"body", _, content}
       ]}
    ] = ast

    content
  end
end
