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
    push_graph(@graph)

    {:ok, %{graph: @graph}}
  end

  def handle_cast({:blank}, state) do
    g =
      Graph.build()
      |> MyComponents.blank([], id: :blank)

    push_graph(g)

    {:noreply, %{state | graph: g}}
  end

  def filter_event({:blank_click}, _, state) do
    push_graph(@graph)

    {:stop, %{state | graph: @graph}}
  end
end
