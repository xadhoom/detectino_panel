import Config

config :detectino_panel, :viewport, %{
  name: :main_viewport,
  default_scene: {DetectinoPanel.Scene.Default, []},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :detectino_panel"]
    }
  ]
}
