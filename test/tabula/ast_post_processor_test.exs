defmodule Tabula.AstPostProcessorTest do
  use ExUnit.Case

  alias Tabula.Board.Card
  alias Tabula.Storage

  import Tabula.AstPostProcessor, only: [modify_ast: 3]

  @ast [
    {"h1", [], ["Returnal (PS5)"]},
    {"p", [], [{"img", [{"src", "returnal.jpg"}, {"alt", "image"}], []}]}
  ]

  @card %Card{
    name: "Returnal",
    list: "Backlog",
    board: "Videogames",
    source_path: "Videogames/Backlog/Returnal.md",
    target_path: "Videogames/Backlog/Returnal.html"
  }

  @context %{
    "created_at" => "2023-10-11 18:24:00",
    "updated_at" => "2023-10-11 18:27:00",
    "tags" => "PS5, PS+ Extra, WTF"
  }

  setup do
    Storage.init()
    :ok
  end

  test ".modify_ast/3 modifies and saves card's context to the storage" do
    modify_ast(@ast, @card, @context)

    assert Storage.get(@card) == %{
             "created_at" => "2023-10-11 18:24:00",
             "updated_at" => "2023-10-11 18:27:00",
             "image_path" => "/assets/images/Videogames/returnal.jpg",
             "tags" => ["PS5", "PS+ Extra", "WTF"],
             "title" => "Returnal (PS5)"
           }
  end

  test ".modify_ast/3 without cover image" do
    ast = [{"h1", [], ["Returnal (PS5)"]}, {"p", [], ["This is okayish game."]}]
    modify_ast(ast, @card, @context)

    assert Storage.get(@card) == %{
             "created_at" => "2023-10-11 18:24:00",
             "updated_at" => "2023-10-11 18:27:00",
             "image_path" => nil,
             "tags" => ["PS5", "PS+ Extra", "WTF"],
             "title" => "Returnal (PS5)"
           }
  end

  test ".modify_ast/3 adds list name to AST" do
    ast = modify_ast(@ast, @card, @context)
    assert Floki.find(ast, "h1 span.list-tag") |> Floki.text() == "Backlog"
  end

  test ".modify_ast/3 adds tags to AST" do
    ast = modify_ast(@ast, @card, @context)
    assert Floki.find(ast, "p.tags span") |> Floki.text(sep: ";") == "PS5;PS+ Extra;WTF"
  end

  test ".modify_ast/3 expands cover image path" do
    ast = modify_ast(@ast, @card, @context)

    assert Floki.find(ast, "img") |> Floki.attribute("src") ==
             ["../../assets/images/Videogames/returnal.jpg"]
  end

  test ".modify_ast/3 wraps HTML layout around AST" do
    ast = modify_ast(@ast, @card, @context)

    assert Floki.find(ast, "html head title") |> Floki.text() == "Returnal (PS5)"

    assert Floki.find(ast, "html body h1") == [
             {"h1", [], [{"span", [{"class", "list-tag"}], ["Backlog"]}, "Returnal (PS5)"]}
           ]
  end
end
