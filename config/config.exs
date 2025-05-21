import Config

import_config "#{config_env()}.exs"

config :tabula, :environment, Mix.env()
