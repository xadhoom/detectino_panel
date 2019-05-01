defmodule DetectinoPanel.Scene.Default do
  @moduledoc false
  use Scenic.Scene

  alias DetectinoPanel.Components, as: MyComponents
  alias Scenic.{Graph, Scene, ViewPort}

  require Logger

  @graph Graph.build()
         |> MyComponents.background([], id: :background)
         |> MyComponents.pin_input([], id: :pin_input)

  def blank(:off) do
    {:ok, %{root_graph: ref}} = ViewPort.info(:main_viewport)
    Scene.cast(ref, {:blank})
  end

  def blank(_) do
    :ok
  end

  def init(_, _) do
    {:ok, %{graph: @graph}, push: @graph}
  end

  def handle_cast({:blank}, state) do
    g =
      Graph.build()
      |> MyComponents.blank([], id: :blank)

    {:noreply, %{state | graph: g}, push: g}
  end

  def filter_event({:blank_click}, _, state) do
    {:halt, %{state | graph: @graph}, push: @graph}
  end

  def filter_event({:keypad_click, :confirm, pin}, _, state) do
    Logger.info("Inserted PIN: #{pin}")

    {:halt, %{state | graph: @graph}, push: @graph}
  end
end
