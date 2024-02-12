defmodule Tabula.IndexPageRendererTest do
  use ExUnit.Case

  alias Tabula.IndexPageRenderer
  alias Tabula.Board
  alias Tabula.Board.Card
  alias Tabula.Board.List

  test ".to_html/1 returns board's HTML" do
    board = %Board{
      name: "Videogames",
      dir: "priv/_boards/Videogames",
      lists: [
        %List{
          name: "Wantlist",
          path: "Wantlist",
          cards: [
            %Card{title: "Alan Wake 2", path: "Wantlist/Alan Wake 2"}
          ]
        },
        %List{
          name: "Backlog",
          path: "Backlog",
          cards: [
            %Card{
              title: "The Last of Us Part I",
              path: "Backlog/The Last of Us Part I"
            },
            %Card{
              title: "The Last of Us Part II Remastered",
              path: "Backlog/The Last of Us Part II Remastered"
            }
          ]
        },
        %List{
          name: "Playing",
          path: "Playing",
          cards: [
            %Card{
              title: "Pathfinder Kingmaker",
              path: "Playing/Pathfinder Kingmaker"
            }
          ]
        },
        %List{
          name: "Finished",
          path: "Finished",
          cards: [
            %Card{
              title: "Oxenfree II: Lost Signals",
              path: "Finished/Oxenfree II Lost Signals"
            },
            %Card{
              title: "Hogwarts Legacy",
              path: "Finished/Hogwarts Legacy"
            },
            %Card{title: "Dead Space", path: "Finished/Dead Space"},
            %Card{
              title: "The Callisto Protocol",
              path: "Finished/The Callisto Protocol"
            }
          ]
        },
        %List{name: "Replay", path: "Replay", cards: []},
        %List{
          name: "Dropped",
          path: "Dropped",
          cards: [
            %Card{
              title: "Baldur's Gate 3",
              path: "Dropped/Baldur's Gate 3"
            }
          ]
        }
        ]
      }

    assert IndexPageRenderer.to_html(board) == String.trim_trailing(~S"""
    <!doctype html>
    <html lang="en">
    <head>
        <meta charset=utf-8>
        <title>Videogames</title>
    </head>
    <body>
    <h1>
         Videogames
    </h1>
    <h2>
        Wantlist
    </h2>
    <ul>
        <li>
            <a href="Wantlist/Alan Wake 2.html" title="Alan Wake 2">Alan Wake 2</a>
        </li>
    </ul>
    <h2>
        Backlog
    </h2>
    <ul>
        <li>
            <a href="Backlog/The Last of Us Part I.html" title="The Last of Us Part I">The Last of Us Part I</a>
        </li>
        <li>
            <a href="Backlog/The Last of Us Part II Remastered.html" title="The Last of Us Part II Remastered">The Last of Us Part II Remastered</a>
        </li>
    </ul>
    <h2>
        Playing
    </h2>
    <ul>
        <li>
            <a href="Playing/Pathfinder Kingmaker.html" title="Pathfinder Kingmaker">Pathfinder Kingmaker</a>
        </li>
    </ul>
    <h2>
        Finished
    </h2>
    <ul>
        <li>
            <a href="Finished/Oxenfree II Lost Signals.html" title="Oxenfree II: Lost Signals">Oxenfree II: Lost Signals</a>
        </li>
        <li>
            <a href="Finished/Hogwarts Legacy.html" title="Hogwarts Legacy">Hogwarts Legacy</a>
        </li>
        <li>
            <a href="Finished/Dead Space.html" title="Dead Space">Dead Space</a>
        </li>
        <li>
            <a href="Finished/The Callisto Protocol.html" title="The Callisto Protocol">The Callisto Protocol</a>
        </li>
    </ul>
    <h2>
        Replay
    </h2>
    <ul>
    </ul>
    <h2>
        Dropped
    </h2>
    <ul>
        <li>
            <a href="Dropped/Baldur's Gate 3.html" title="Baldur's Gate 3">Baldur's Gate 3</a>
        </li>
    </ul>
    </body>
    </html>
    """)
  end
end
