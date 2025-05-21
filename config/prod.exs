import Config

config :tabula, :base_boards_dir, System.get_env("TABULA_BOARDS_DIR", "./priv/boards/")
config :tabula, :release_dir, System.get_env("TABULA_RELEASE_DIR", "./release/prod/")
config :tabula, :web_server_port, 80
