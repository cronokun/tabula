defmodule Tabula.Web.Server do
  @moduledoc "Run simple HTTP server to serve static files for boards and cards."

  use Plug.Router

  plug(Plug.Logger)
  plug(Plug.Static, at: "/", from: "release/")

  plug(:match)
  plug(:dispatch)

  post "/rebuild" do
    Mix.Tasks.Build.Board.run([])
    Mix.Tasks.Build.Index.run([])
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  def run do
    webserver = {Plug.Cowboy, plug: __MODULE__, scheme: :http, options: [port: 80]}
    {:ok, _} = Supervisor.start_link([webserver], strategy: :one_for_one)
    Process.sleep(:infinity)
  end
end
