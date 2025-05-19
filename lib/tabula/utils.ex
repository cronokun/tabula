defmodule Tabula.Utils do
  @moduledoc "Collection of usefull utility functions."

  def rel_due_date(due_date) when is_binary(due_date) do
    due_date
    |> Date.from_iso8601!()
    |> rel_due_date()
  end

  def rel_due_date(due_date) do
    is_same_year = Date.utc_today().year == due_date.year

    if is_same_year do
      Calendar.strftime(due_date, "%b %d")
    else
      Calendar.strftime(due_date, "%b %d, %Y")
    end
  end

  def list_dirs(dir) do
    System.cmd(
      "fd",
      ["-a", "--type", "directory", "-d", "1"],
      cd: dir,
      into: [],
      lines: 1024
    )
    |> elem(0)
  end

  def open_in_mvim(url) do
    "mvim://open?url=file://#{url}"
  end
end
