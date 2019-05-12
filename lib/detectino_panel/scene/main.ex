defmodule DetectinoPanel.Scene.Main do
  @moduledoc false
  use Scenic.Scene

  alias Detectino.Api
  alias DetectinoPanel.Components, as: MyComponents
  alias DetectinoPanel.Scene.Helpers.Screensaver
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

  def handle_info(:idle, %{blanked: true} = state) do
    ViewPort.set_root(:main_viewport, {DetectinoPanel.Scene.Default, blanked: true})

    {:noreply, state}
  end

  def handle_info(:idle, %{blanked: false} = state) do
    ViewPort.set_root(:main_viewport, {DetectinoPanel.Scene.Default, blanked: false})

    {:noreply, state}
  end

  def handle_info({:check_pin_response, {:error, _}}, state) do
    g =
      Graph.build()
      |> MyComponents.pin_error([])

    state =
      %{state | graph: g}
      |> schedule_idle()

    {:noreply, state, push: g}
  end

  def handle_info({:check_pin_response, :ok}, state) do
    {:noreply, state}
  end

  def filter_event({:blank_click}, _, state) do
    {:halt, %{state | graph: @graph, blanked: false}, push: @graph}
  end

  def filter_event({:keypad_click, :confirm, pin}, _, state) do
    Logger.info("Inserted PIN: #{pin}")

    Api.check_pin(pin)

    {:halt, %{state | graph: @graph}, push: @graph}
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

  defp schedule_idle(%{idle_timer: nil} = state) do
    tref = Process.send_after(self(), :idle, 5000)

    %{state | idle_timer: tref}
  end

  defp schedule_idle(%{idle_timer: tref} = state) when is_reference(tref) do
    Process.cancel_timer(tref)

    schedule_idle(%{state | idle_timer: nil})
  end
end
