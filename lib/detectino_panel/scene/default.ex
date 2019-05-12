defmodule DetectinoPanel.Scene.Default do
  @moduledoc false
  use Scenic.Scene

  alias DetectinoPanel.Components, as: MyComponents
  alias Scenic.{Graph, ViewPort}

  require Logger

  @graph Graph.build()
         |> MyComponents.background([], id: :background)

  defmodule State do
    @moduledoc false
    defstruct graph: nil, blanked: false
  end

  def init(opts, _) do
    blanked? = Keyword.get(opts, :blanked, false)

    g =
      case blanked? do
        false ->
          @graph

        true ->
          Graph.build()
          |> MyComponents.blank([], id: :blank)
      end

    {:ok, %State{graph: g, blanked: blanked?}, push: g}
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

  def filter_event({:background_click}, _, state) do
    ViewPort.set_root(:main_viewport, {DetectinoPanel.Scene.Main, nil})

    {:halt, state}
  end
end
