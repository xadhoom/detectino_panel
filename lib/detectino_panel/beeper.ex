defmodule DetectinoPanel.Beeper do
  @moduledoc """
  Simple beeper driver, driven by alarm events
  """
  use GenServer

  alias Registry.DetectinoEvents

  require Logger

  defmodule State do
    @moduledoc false
    defstruct foo: nil
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(_) do
    register_to_events()
    Logger.info("Started beeper backend")

    {:ok, %State{}}
  end

  def handle_info({:exit_timer_start, %{"partition" => part}}, state) do
    Logger.debug("Partition #{part} started exit")

    {:noreply, state}
  end

  def handle_info({:exit_timer_stop, %{"partition" => part}}, state) do
    Logger.debug("Partition #{part} stopped exit")

    {:noreply, state}
  end

  def handle_info({:exit_timer_start, %{"name" => sensor}}, state) do
    Logger.debug("Sensor #{sensor} started entry countdown")

    {:noreply, state}
  end

  def handle_info({:exit_timer_stop, %{"name" => sensor}}, state) do
    Logger.debug("Sensor #{sensor} stopped entry countdown")

    {:noreply, state}
  end

  defp register_to_events do
    [:exit_timer_start, :exit_timer_stop, :entry_timer_start, :entry_timer_stop]
    |> Enum.each(fn event ->
      {:ok, _pid} = Registry.register(DetectinoEvents, event, [])
    end)
  end
end
