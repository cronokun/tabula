defmodule Tabula.MixProject do
  use Mix.Project

  def project do
    [
      app: :tabula,
      version: "0.6.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {Tabula.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:earmark_parser, "~> 1.4"},
      {:floki, "~> 0.37"},
      {:yaml_elixir, "~> 2.11"},
      {:plug_cowboy, "~> 2.7"},
      {:file_system, "~> 1.1"}
    ]
  end

  defp aliases do
    [
      build: ["build.board", "build.index"]
    ]
  end
end
