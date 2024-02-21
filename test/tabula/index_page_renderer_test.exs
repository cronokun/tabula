defmodule Tabula.IndexPageRendererTest do
  use ExUnit.Case

  alias Tabula.IndexPageRenderer
  alias Tabula.Board
  alias Tabula.Storage

  setup do
    setup_storage()

    {:ok, %{board: test_board()}}
  end

  test ".to_html/1 returns board's HTML", %{board: board} do
    assert IndexPageRenderer.to_html(board) ==
             String.trim_trailing(~S"""
             <!doctype html>
             <html lang="en">
                 <head>
                     <meta charset="utf-8">
                     <link rel="stylesheet" href="../assets/css/board.css">
                     <title>
                         Videogames
                     </title>
                 </head>
                 <body class="videogames">
                     <h1>
                         Videogames
                     </h1>
                     <section>
                         <h2>
                             Wantlist
                         </h2>
                         <ul>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Wantlist/Alan Wake 2.html" title="Alan Wake 2"><img src="..alan-wake-2.jpg" alt="Alan Wake 2" class="cover">Alan Wake 2</a>
                             </li>
                         </ul>
                     </section>
                     <section>
                         <h2>
                             Backlog
                         </h2>
                         <ul>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Backlog/The Last of Us Part I.html" title="The Last of Us Part I"><img src="..last-of-us-part1.jpg" alt="The Last of Us Part I" class="cover">The Last of Us Part I</a>
                             </li>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Backlog/The Last of Us Part II Remastered.html" title="The Last of Us Part II Remastered"><img src="..last-of-us-part2-remastered.jpg" alt="The Last of Us Part II Remastered" class="cover">The Last of Us Part II Remastered</a>
                             </li>
                         </ul>
                     </section>
                     <section>
                         <h2>
                             Playing
                         </h2>
                         <ul>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Playing/Pathfinder Kingmaker.html" title="Pathfinder: Kingmaker"><img src="..pathfinder-kingmaker.jpg" alt="Pathfinder: Kingmaker" class="cover">Pathfinder: Kingmaker</a>
                             </li>
                         </ul>
                     </section>
                     <section>
                         <h2>
                             Finished
                         </h2>
                         <ul>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Finished/Oxenfree II Lost Signals.html" title=""><img src="../assets/images/no-cover.png" alt="" class="no-cover">Oxenfree II: Lost Signals</a>
                             </li>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Finished/Hogwarts Legacy.html" title=""><img src="../assets/images/no-cover.png" alt="" class="no-cover">Hogwarts Legacy</a>
                             </li>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Finished/Dead Space.html" title="Dead Space"><img src="..dead-space.jpg" alt="Dead Space" class="cover">Dead Space</a>
                             </li>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Finished/The Callisto Protocol.html" title="The Callisto Protocol"><img src="..the-callisto-protocol.jpg" alt="The Callisto Protocol" class="cover">The Callisto Protocol</a>
                             </li>
                         </ul>
                     </section>
                     <section>
                         <h2>
                             Replay
                         </h2>
                         <ul>
                         </ul>
                     </section>
                     <section>
                         <h2>
                             Dropped
                         </h2>
                         <ul>
                             <li class="card">
                                 <a href="/Users/crono/Developer/tabula/release/Videogames/Dropped/Baldur's Gate 3.html" title="Baldur's Gate 3"><img src="..baldurs-gate-3.jpg" alt="Baldur's Gate 3" class="cover">Baldur's Gate 3</a>
                             </li>
                         </ul>
                     </section>
                 </body>
             </html>
             """)
  end

  defp test_board do
    Board.build(
      %{
        "board" => "Videogames",
        "lists" => [
          %{"cards" => ["Alan Wake 2"], "name" => "Wantlist"},
          %{
            "cards" => ["The Last of Us Part I", "The Last of Us Part II Remastered"],
            "name" => "Backlog"
          },
          %{"cards" => ["Pathfinder Kingmaker"], "name" => "Playing"},
          %{
            "cards" => [
              "Oxenfree II: Lost Signals",
              "Hogwarts Legacy",
              "Dead Space",
              "The Callisto Protocol"
            ],
            "name" => "Finished"
          },
          %{"cards" => nil, "name" => "Replay"},
          %{"cards" => ["Baldur's Gate 3"], "name" => "Dropped"}
        ]
      },
      "test"
    )
  end

  defp setup_storage do
    Storage.init("Test Board")

    Storage.add_card("Alan Wake 2", %{"title" => "Alan Wake 2", "image_path" => "alan-wake-2.jpg"})

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

    Storage.add_card("Oxenfree II Lost Signals", %{ "title" => "Oxenfree II Lost Signals" })
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
