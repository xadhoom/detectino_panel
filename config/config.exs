import Config

config :logger,
  backends: [:console],
  level: :debug

# Customize non-Elixir parts of the firmware.  See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.
config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.
config :shoehorn,
  init: [:nerves_runtime, :nerves_network, :nerves_firmware_ssh],
  app: Mix.Project.config()[:app]

# Detectino APIs config
config :detectino_panel, :detectino_api,
  username: "admin@local",
  password: "admin",
  server: "http://your.detectino:8888",
  ws_ep: "ws://your.detectino:8888/socket/websocket"

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

import_config "config.#{Mix.Project.config()[:target]}.exs"

# config secrets
import_config "config.secrets.exs"
import_config "config.#{Mix.Project.config()[:target]}.secrets.exs"
