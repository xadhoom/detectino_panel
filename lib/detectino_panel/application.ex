defmodule DetectinoPanel.Application do
  @moduledoc false

  @env Mix.env()
  @target Mix.Project.config()[:target]

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: DetectinoPanel.Supervisor]
    Supervisor.start_link(children(@target, @env), opts)
  end

  # List all child processes to be supervised
  def children("host", :test) do
    import Supervisor.Spec
    _main_viewport_config = Application.get_env(:detectino_panel, :viewport)

    [
      supervisor(Scenic, viewports: [])
    ]
  end

  def children("host", _) do
    common_children()
  end

  def children(_target, _env) do
    [
      worker(RpiBacklight.AutoDimmer, [
        [
          timeout: 15,
          brightness: 225,
          callback: {DetectinoPanel.Scene.Helpers.Screensaver, :blank}
        ]
      ])
    ] ++ common_children()
  end

  defp common_children do
    main_viewport_config = Application.get_env(:detectino_panel, :viewport)

    [
      {Registry, keys: :unique, name: Registry.DetectinoApi},
      {Registry, keys: :duplicate, name: Registry.DetectinoEvents},
      {DetectinoPanel.Beeper, []},
      supervisor(Detectino.Api.Supervisor, [[]]),
      supervisor(Scenic, viewports: [main_viewport_config])
    ]
  end
end
