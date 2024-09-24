import Config

boards_dir = System.get_env("TABULA_BOARDS_DIR", "./priv/boards/")
release_dir = System.get_env("TABULA_RELEASE_DIR", "./release/")

config :tabula, :base_boards_dir, boards_dir
config :tabula, :release_dir, release_dir
