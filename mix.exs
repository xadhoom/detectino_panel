defmodule DetectinoPanel.MixProject do
  @moduledoc false
  use Mix.Project

  @otp_app :detectino_panel
  @target System.get_env("MIX_TARGET") || "host"

  def project do
    [
      app: @otp_app,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      target: @target,
      archives: [nerves_bootstrap: "~> 1.6"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      lockfile: "mix.lock.#{@target}",
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@otp_app, release()}],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_target: [run: :host, test: :host],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@otp_app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {DetectinoPanel.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves, "~> 1.5", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.5"},
      {:scenic, "~> 0.9"},
      {:scenic_sensor, "~> 0.7"},
      {:rpi_backlight, path: "../rpi_backlight"},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:phoenix_gen_socket_client, "~> 2.1"},
      {:websocket_client, "~> 1.3"},
      {:poison, "~> 3.0"},
      {:timex, "~> 3.5"},
      # dev and debug stuff
      {:observer_cli, "~> 1.4"},
      {:bypass, "~> 1.0", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
    ] ++ deps(@target)
  end

  # Specify target specific dependencies
  defp deps("host") do
    [
      {:scenic_driver_glfw, "~> 0.9"}
    ]
  end

  defp deps(target) do
    [
      {:nerves_runtime, "~> 0.6"},
      {:nerves_network, "~> 0.3"},
      {:nerves_firmware_ssh, "~> 0.3"},
      {:scenic_driver_nerves_rpi, "~> 0.10"},
      {:scenic_driver_nerves_touch, "~> 0.10"}
    ] ++ system(target)
  end

  defp system("rpi3"), do: [{:nerves_system_rpi3, "~> 1.8", runtime: false}]

  defp system(target), do: Mix.raise("Unknown MIX_TARGET: #{target}")
end
