defmodule Tabula.Mardown.ParserTest do
  use ExUnit.Case, async: true

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

  describe "parse/2" do
    test "parses markdown content to AST" do
      content =
        """
        # Hello World!

        ![image](cover.jpg)

        All your base are belong to us.

        This is **bold** statement.

        - Foo
        - Bar
        """

      assert [
               {"h1", [], ["Hello World!"]},
               {"p", [], [{"img", [{"src", "cover.jpg"}, {"alt", "image"}], []}]},
               {"p", [], ["All your base are belong to us."]},
               {"p", [], ["This is ", {"strong", [], ["bold"]}, " statement."]},
               {"ul", [], [{"li", [], ["Foo"]}, {"li", [], ["Bar"]}]}
             ] = Parser.parse(content)
    end

    test "parses checklists" do
      content =
        """
        - [x] One
        - [ ] Two
        - [ ] Three
        """

      assert [
               {
                 "ul",
                 [{"class", "checklist"}],
                 [
                   {"li", [], [@checked_checkbox, " One"]},
                   {"li", [], [@unchecked_checkbox, " Two"]},
                   {"li", [], [@unchecked_checkbox, " Three"]}
                 ]
               }
             ] = Parser.parse(content)
    end

    test "parses checklists with inner markup" do
      content =
        """
        - [x] This is **something** or _something_ other.
        - [ ] **Test:** this is a test.
        """

      assert [
               {
                 "ul",
                 [{"class", "checklist"}],
                 [
                   {
                     "li",
                     [],
                     [
                       @checked_checkbox,
                       "This is ",
                       {"strong", [], ["something"]},
                       " or ",
                       {"em", [], ["something"]},
                       " other."
                     ]
                   },
                   {
                     "li",
                     [],
                     [
                       @unchecked_checkbox,
                       {"strong", [], ["Test:"]},
                       " this is a test."
                     ]
                   }
                 ]
               }
             ] = Parser.parse(content)
    end

    test "parses description lists" do
      content =
        """
        Genre:: Adventure, Role Playing, Strategy
        Developer:: Larian Studios
        Publisher:: Larian Studios
        Release Date:: 3 Aug, 2023
        Platform:: Steam, macOS
        """

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
             ] = Parser.parse(content)
    end

    test "parses markup inside description lists" do
      content =
        """
        Foobar:: This is **bold!** move
        Link:: https://example.com/
        """

      assert [
               {"dl", [],
                [
                  {"dt", [], ["Foobar"]},
                  {"dd", [], ["This is ", {"strong", [], ["bold!"]}, " move"]},
                  {"dt", [], ["Link"]},
                  {"dd", [],
                   [{"a", [{"href", "https://example.com/"}], ["https://example.com/"]}]}
                ]}
             ] = Parser.parse(content)
    end

    test "otherwise parses Markdown as usual" do
      content =
        """
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
        """

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
             ] = Parser.parse(content)
    end
  end
end
