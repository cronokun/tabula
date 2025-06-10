defmodule Tabula.MixProject do
  use Mix.Project

  def project do
    [
      app: :tabula,
      version: "0.6.6",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: releases()
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

  defp releases do
    [
      prod: [
        steps: [&copy_extra_files/1, :assemble]
      ],
      dev: [
        steps: [&copy_extra_files/1, :assemble]
      ]
    ]
  end

  defp copy_extra_files(rel) do
    IO.puts("Copying assets files")
    priv_dir = :code.priv_dir(:tabula)
    css_dir = Path.join(priv_dir, "/static/assets/css/")
    img_dir = Path.join(priv_dir, "/static/assets/images/")
    File.mkdir_p!(css_dir)
    File.mkdir_p!(img_dir)
    File.cp_r!("./assets/css/", css_dir)
    File.cp_r!("./assets/images/", img_dir)
    rel
  end
end
