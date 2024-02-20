defmodule Tabula.Markdown.ParserTest do
  use ExUnit.Case

  alias Tabula.Markdown.Parser

  @checked_checkbox {
    "input",
    [{"checked", ""}, {"disabled", ""}, {"type", "checkbox"}],
    []
  }

  @unchecked_checkbox {
    "input",
    [{"disabled", ""}, {"type", "checkbox"}],
    []
  }

  test ".parse/1 pasres simple task list items" do
    ast =
      Parser.parse(~S"""
      - [x] foo
      - [ ] bar
      - [x] car
      """)

    assert [
             {"ul", [{"class", "checklist"}],
              [
                {"li", [], [@checked_checkbox, " foo"]},
                {"li", [], [@unchecked_checkbox, " bar"]},
                {"li", [], [@checked_checkbox, " car"]}
              ]}
           ] = ast
  end

  test ".parse/1 parses taks list items with formatting" do
    ast =
      Parser.parse(~S"""
      - [x] **Hello:** World!
      - [ ] **Foobar:** Lorem ipsum.
      """)

    assert [
             {"ul", [{"class", "checklist"}],
              [
                {"li", [],
                 [
                   @checked_checkbox,
                   [{"strong", [], ["Hello:"]}, " World!"]
                 ]},
                {"li", [],
                 [
                   @unchecked_checkbox,
                   [{"strong", [], ["Foobar:"]}, " Lorem ipsum."]
                 ]}
              ]}
           ] = ast
  end

  test ".parse/1 parses description lists" do
    ast =
      Parser.parse(~S"""
      Genre:: Adventure, Role Playing, Strategy
      Developer:: Larian Studios
      Publisher:: Larian Studios
      Release Date:: 3 Aug, 2023
      Platform:: Steam, macOS
      """)

    assert [
             {"dl", [],
              [
                {"dt", [], ["Genre"]},
                {"dd", [], ["Adventure, Role Playing, Strategy"]},
                {"dt", [], ["Developer"]},
                {"dd", [], ["Larian Studios"]},
                {"dt", [], ["Publisher"]},
                {"dd", [], ["Larian Studios"]},
                {"dt", [], ["Release Date"]},
                {"dd", [], ["3 Aug, 2023"]},
                {"dt", [], ["Platform"]},
                {"dd", [], ["Steam, macOS"]}
              ]}
           ] = ast
  end

  test ".parse/1 correctly parses Markdown inside description lists" do
    ast =
      Parser.parse(~S"""
      Foobar:: This is **bold!** move
      Link:: https://example.com/
      """)

    assert [
             {"dl", [],
              [
                {"dt", [], ["Foobar"]},
                {"dd", [], ["This is ", {"strong", [], ["bold!"]}, " move"]},
                {"dt", [], ["Link"]},
                {"dd", [], [{"a", [{"href", "https://example.com/"}], ["https://example.com/"]}]}
              ]}
           ] = ast
  end

  test ".parse/1 otherwise parses Markdown as usual" do
    ast =
      Parser.parse(~S"""
      1.  List item one.

          List item one continued with a second paragraph followed by an
          Indented block.

              $ ls *.sh
              $ mv *.sh ~/tmp

          List item continued with a third paragraph.

      2.  List item two continued with an open block.

          This paragraph is part of the preceding list item.

          1. This list is nested and does not require explicit item continuation.

             This paragraph is part of the preceding list item.

          2. List item b.

          This paragraph belongs to item two of the outer list.
      """)

    assert [
             {"ol", [],
              [
                {"li", [],
                 [
                   {"p", [], [" List item one."]},
                   {"p", [],
                    [
                      "List item one continued with a second paragraph followed by an\nIndented block."
                    ]},
                   {"pre", [], [{"code", [], ["$ ls *.sh\n$ mv *.sh ~/tmp"]}]},
                   {"p", [], ["List item continued with a third paragraph."]}
                 ]},
                {"li", [],
                 [
                   {"p", [], [" List item two continued with an open block."]},
                   {"p", [], ["This paragraph is part of the preceding list item."]},
                   {"ol", [],
                    [
                      {"li", [],
                       [
                         {"p", [],
                          [
                            "This list is nested and does not require explicit item continuation."
                          ]},
                         {"p", [], ["This paragraph is part of the preceding list item."]}
                       ]},
                      {"li", [], [{"p", [], ["List item b."]}]}
                    ]},
                   {"p", [], ["This paragraph belongs to item two of the outer list."]}
                 ]}
              ]}
           ] = ast
  end
end
