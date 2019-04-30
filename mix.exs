defmodule DetectinoPanel.MixProject do
  @moduledoc false
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  def project do
    [
      app: :detectino_panel,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      target: @target,
      archives: [nerves_bootstrap: "~> 1.0"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      lockfile: "mix.lock.#{@target}",
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
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
      {:nerves, "~> 1.3", runtime: false},
      {:shoehorn, "~> 0.4"},
      {:ring_logger, "~> 0.5"},
      {:scenic, "~> 0.9"},
      {:scenic_sensor, "~> 0.7"},
      {:rpi_backlight, path: "../rpi_backlight"},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:phoenix_gen_socket_client, "~> 2.1"},
      {:websocket_client, "~> 1.3"},
      {:poison, "~> 3.0"},
      # dev and debug stuff
      {:observer_cli, "~> 1.4"},
      # TODO fix once bypass and cowboy settles
      {:bypass, "~> 1.0", only: :test},
      {:plug_cowboy, "~> 2.0", only: :test},
      {:cowboy, "~> 2.0", only: :test},
      # eof TODO
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
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
      {:scenic_driver_nerves_rpi,
       git: "git@github.com:boydm/scenic_driver_nerves_rpi.git", branch: "v0.9.0"},
      {:scenic_driver_nerves_touch, "~> 0.9"}
    ] ++ system(target)
  end

  defp system("rpi3"), do: [{:nerves_system_rpi3, "~> 1.5", runtime: false}]

  defp system(target), do: Mix.raise("Unknown MIX_TARGET: #{target}")
end
