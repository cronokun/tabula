defmodule Tabula.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    env = Application.get_env(:tabula, :environment)
    children = children(env)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tabula.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children(:prod) do
    [
      {Tabula.Storage, nil},
      {Tabula.Watcher, nil},
      {Tabula.Web.Server, nil},
      {Tabula.Rebuild, nil}
    ]
  end

  defp children(:dev) do
    [
      {Tabula.Storage, nil},
      {Tabula.Watcher, nil},
      {Tabula.Web.Server, nil},
      {Tabula.Rebuild, nil}
    ]
  end

  defp children(_) do
    [
      {Tabula.Storage, nil},
      {Tabula.Watcher, nil}
    ]
  end
end
