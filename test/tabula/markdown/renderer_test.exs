defmodule Tabula.Markdown.RendererTest do
  use ExUnit.Case

  alias Tabula.Markdown.Renderer

  test ".to_html/1 renders inline tags" do
    ast = [{"strong", [], ["foobar"]}]
    assert Renderer.to_html(ast) == "<strong>foobar</strong>"
  end

  test ".to_html/1 renders tag attributes" do
    ast = [{"p", [{"class", "foobar"}], ["All your base are belong to us!"]}]

    assert Renderer.to_html(ast) ==
             String.trim(~S"""
             <p class="foobar">
                 All your base are belong to us!
             </p>
             """)

    ast = [
      {"a", [{"href", "https://localhost/foobar"}, {"class", "main-link"}], ["Foobar (local)"]}
    ]

    assert Renderer.to_html(ast) ==
             "<a href=\"https://localhost/foobar\" class=\"main-link\">Foobar (local)</a>"
  end

  test ".to_html/1 renders tags without content" do
    ast = [{"hr", [], []}]
    assert Renderer.to_html(ast) == "<hr>"
  end

  test ".to_html/1 renders simple multiline tags" do
    ast = [
      {"ul", [],
       [
         {"li", [], ["Foo"]},
         {"li", [], ["Bar"]},
         {"li", [], ["Car"]}
       ]}
    ]

    assert Renderer.to_html(ast) ==
             String.trim(~S"""
             <ul>
                 <li>Foo</li>
                 <li>Bar</li>
                 <li>Car</li>
             </ul>
             """)
  end

  test ".to_html/1 render multiline checklists" do
    ast = [
      {"ul", [],
       [
         {"li", [],
          [
            {"input", [{"checked", ""}, {"disabled", ""}, {"type", "checkbox"}], []},
            {"strong", [], ["Platinum"]},
            ": Collect all Trophies."
          ]}
       ]}
    ]

    assert Renderer.to_html(ast) ==
             String.trim(~S"""
             <ul>
                 <li>
                     <input checked="" disabled="" type="checkbox">
                     <strong>Platinum</strong>
                     : Collect all Trophies.
                 </li>
             </ul>
             """)
  end

  test ".to_html/1 renders multiline content with proper indent" do
    ast = [
      {"section", [{"id", "section-1"}],
       [
         {"h1", [], ["Section 1"]},
         {"p", [], ["All your base are belong to us!"]},
         {"img", [{"src", "meme.jpeg"}, {"alt", "meme"}], []}
       ]},
      {"section", [{"id", "section-2"}],
       [
         {"p", [], ["Lorem ipsum etc."]},
         {"ul", [],
          [
            {"li", [], ["foo"]},
            {"li", [], ["bar"]},
            {"li", [], ["car"]}
          ]}
       ]}
    ]

    assert Renderer.to_html(ast) ==
             String.trim(~S"""
             <section id="section-1">
                 <h1>
                     Section 1
                 </h1>
                 <p>
                     All your base are belong to us!
                 </p>
                 <img src="meme.jpeg" alt="meme">
             </section>
             <section id="section-2">
                 <p>
                     Lorem ipsum etc.
                 </p>
                 <ul>
                     <li>foo</li>
                     <li>bar</li>
                     <li>car</li>
                 </ul>
             </section>
             """)
  end
end
