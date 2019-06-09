defmodule DetectinoPanel.Scene.Default do
  @moduledoc false
  use Scenic.Scene

  alias Detectino.Api.Events
  alias DetectinoPanel.Components, as: MyComponents
  alias Scenic.{Graph, ViewPort}

  import Scenic.Primitives, only: [{:text, 3}]

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

    Events.subscribe(:timer)

    {:ok, %State{graph: g, blanked: blanked?}, push: g}
  end

  def handle_cast({:blank}, state) do
    g =
      Graph.build()
      |> MyComponents.blank([], id: :blank)

    {:noreply, %{state | graph: g, blanked: true}, push: g}
  end

  def handle_info({:timer, _}, %{blanked: true} = state) do
    {:noreply, state}
  end

  def handle_info({:timer, current_dt}, %{blanked: false} = state) do
    g =
      @graph
      |> text(format_dt(current_dt),
        fill: :antique_white,
        text_align: :center_middle,
        font_size: 32,
        translate: {400, 200}
      )

    {:noreply, %{state | graph: g}, push: g}
  end

  def filter_event({:blank_click}, _, state) do
    {:halt, %{state | graph: @graph, blanked: false}, push: @graph}
  end

  def filter_event({:background_click}, _, state) do
    ViewPort.set_root(:main_viewport, {DetectinoPanel.Scene.Main, nil})

    {:halt, state}
  end

  defp format_dt(dt) do
    Timex.format!(dt, " %H:%M:%S\n%A, %B %-d %Y", :strftime)
  end
end
