defmodule Tabula.Assets do
  @moduledoc "Prepare global assets (images and css files)."

  @release_dir Application.compile_env(:tabula, :release_dir)

  require Logger

  def build do
    Logger.info("Building assets files")
    priv_dir = :code.priv_dir(:tabula)
    source_css_dir = Path.join(priv_dir, "/static/assets/css/")
    source_img_dir = Path.join(priv_dir, "/static/assets/images/")
    target_css_dir = Path.join(@release_dir, "/assets/css/")
    target_img_dir = Path.join(@release_dir, "/assets/images/")

    File.mkdir_p!(target_css_dir)
    File.mkdir_p!(target_img_dir)
    File.cp_r!(source_css_dir, target_css_dir)
    File.cp_r!(source_img_dir, target_img_dir)
  end
end
