defmodule DetectinoPanel.Scene.Active.Main do
  @moduledoc """
             Main ViewPort to be shown when fully authed
             """ && false
  use Scenic.Scene

  alias Detectino.Api
  alias DetectinoPanel.Components, as: MyComponents
  alias DetectinoPanel.Scene.Helpers.Screensaver
  alias Scenic.{Graph, Scene, ViewPort}

  import Scenic.Primitives, only: [{:rect, 3}]

  require Logger

  @def_graph Graph.build()
             |> rect({800, 480}, fill: :light_gray)
             |> MyComponents.top_bar([], id: :top_bar)

  @graph @def_graph
         |> MyComponents.intrusion_menu([], id: :intrusion_menu)

  @idle_timeout 15_000

  def blank(:off) do
    {:ok, %{root_graph: ref}} = ViewPort.info(:main_viewport)
    Scene.cast(ref, {:blank})
  end

  def blank(_) do
    :ok
  end

  defmodule State do
    @moduledoc false
    defstruct graph: nil, blanked: false, idle_timer: nil
  end

  def init(_, _) do
    state =
      %State{graph: @graph}
      |> schedule_idle()

    {:ok, state, push: @graph}
  end

  def handle_cast({:blank}, state) do
    g =
      Graph.build()
      |> MyComponents.blank([], id: :blank)

    {:noreply, %{state | graph: g, blanked: true}, push: g}
  end

  def handle_info(:idle, %{blanked: blanked} = state) when is_boolean(blanked) do
    ViewPort.set_root(:main_viewport, {DetectinoPanel.Scene.Default, blanked: blanked})

    {:noreply, state}
  end

  def filter_event({:blank_click}, _, state) do
    {:halt, %{state | graph: @graph, blanked: false}, push: @graph}
  end

  def filter_event({:background_click}, _, state) do
    {:halt, state}
  end

  # :app_interaction is sent upwards from all inner components that
  # receive an input to signal here that something has been done, so
  # we can do actions like resetting idle timers, screensave timers and so on...
  def filter_event(:app_interaction, _from, state) do
    Screensaver.signal_screensaver()
    state = state |> schedule_idle()

    {:halt, state}
  end

  def filter_event({:open_section, module}, _from, state) do
    g =
      @def_graph
      |> MyComponents.add_module(module, [], translate: {0, 80})

    {:halt, %{state | graph: g}, push: g}
  end

  defp schedule_idle(%{idle_timer: nil} = state) do
    tref = Process.send_after(self(), :idle, @idle_timeout)

    %{state | idle_timer: tref}
  end

  defp schedule_idle(%{idle_timer: tref} = state) when is_reference(tref) do
    IO.inspect(:rescheduling)
    Process.cancel_timer(tref)

    schedule_idle(%{state | idle_timer: nil})
  end
end
