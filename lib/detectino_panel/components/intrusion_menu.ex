defmodule DetectinoPanel.Components.IntrusionMenu do
  @moduledoc false
  use Scenic.Component

  alias DetectinoPanel.Components, as: MyComponents
  alias Scenic.{Graph}

  require Logger

  @graph Graph.build()
         |> MyComponents.scenario_button([],
           id: :scenario_button,
           translate: {50, 140}
         )
         |> MyComponents.lock_button([],
           id: :lock_button,
           translate: {300, 140}
         )
         |> MyComponents.event_button([],
           id: :event_button,
           translate: {550, 140}
         )

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  defmodule State do
    @moduledoc false
    defstruct graph: nil
  end

  def init(_, _) do
    state = %State{graph: @graph}

    {:ok, state, push: @graph}
  end

  def filter_event({:scenario_click}, _from, state) do
    alias DetectinoPanel.Components.ScenarioList
    Logger.debug("Scenario selected!")

    send_event(:app_interaction)

    {:cont, {:open_section, ScenarioList}, state}
  end

  def filter_event({:lock_click}, _from, state) do
    alias DetectinoPanel.Components.PartitionList
    Logger.debug("Partitions selected!")

    send_event(:app_interaction)

    {:cont, {:open_section, PartitionList}, state}
  end

  def filter_event({:event_click}, _from, state) do
    alias DetectinoPanel.Components.EventList
    Logger.debug("Event list selected!")

    send_event(:app_interaction)

    {:cont, {:open_section, EventList}, state}
  end
end
