defmodule DetectinoPanel.Scene.Helpers.Screensaver do
  @moduledoc """
  Helpers to interact with screensaver.
  """

  @target System.get_env("MIX_TARGET") || "host"

  if @target == "host" do
    def signal_screensaver do
      :ok
    end
  else
    def signal_screensaver do
      alias RpiBacklight.AutoDimmer
      AutoDimmer.activate()
    end
  end
end
