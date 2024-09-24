defmodule Tabula.Web.Server do
  @moduledoc "Run simple HTTP server to serve static files for boards and cards."

  @release_dir Application.compile_env(:tabula, :release_dir)

  use Plug.Router

  plug(Plug.Logger)
  plug(Plug.Static, at: "/", from: @release_dir)

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  def child_spec(_args) do
    Plug.Cowboy.child_spec(
      plug: __MODULE__,
      scheme: :http,
      options: [port: 80]
    )
  end
end
