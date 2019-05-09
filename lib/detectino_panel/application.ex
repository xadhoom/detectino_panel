defmodule DetectinoPanel.Application do
  @moduledoc false

  @env Mix.env()
  @target Mix.Project.config()[:target]

  use Application

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
    import Supervisor.Spec
    main_viewport_config = Application.get_env(:detectino_panel, :viewport)

    [
      supervisor(Scenic, viewports: [main_viewport_config]),
      supervisor(Detectino.Api.Supervisor, [[]])
    ]
  end

  def children(_target, _env) do
    import Supervisor.Spec, warn: false
    main_viewport_config = Application.get_env(:detectino_panel, :viewport)

    [
      worker(RpiBacklight.AutoDimmer, [
        [timeout: 15, brightness: 225, callback: {DetectinoPanel.Scene.Default, :blank}]
      ]),
      supervisor(Scenic, viewports: [main_viewport_config]),
      supervisor(Detectino.Api.Supervisor, [[]])
    ]
  end
end
