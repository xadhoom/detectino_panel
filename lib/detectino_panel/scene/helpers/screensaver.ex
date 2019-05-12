defmodule DetectinoPanel.Scene.Helpers.Screensaver do
  @moduledoc """
  Helpers to interact with screensaver.
  """
  alias Scenic.{Scene, ViewPort}

  @target System.get_env("MIX_TARGET") || "host"

  def blank(:off) do
    {:ok, %{root_graph: ref}} = ViewPort.info(:main_viewport)
    Scene.cast(ref, {:blank})
  end

  def blank(_) do
    :ok
  end

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
