defmodule Tabula.MixProject do
  use Mix.Project

  def project do
    [
      app: :tabula,
      version: "0.5.1",
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
      {:floki, "~> 0.36.2"},
      {:yaml_elixir, "~> 2.9"},
      {:plug_cowboy, "~> 2.0"},
      {:file_system, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      build: ["build.board", "build.index"]
    ]
  end
end
