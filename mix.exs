defmodule Tabula.MixProject do
  use Mix.Project

  def project do
    [
      app: :tabula,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:earmark_parser, "~> 1.4"},
      {:floki, "~> 0.36.2"},
      {:yaml_elixir, "~> 2.9"}
    ]
  end

  defp aliases do
    [
      build: ["build.board", "build.index"]
    ]
  end
end
