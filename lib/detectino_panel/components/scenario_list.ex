defmodule DetectinoPanel.Components.ScenarioList do
  @moduledoc false
  use Scenic.Component

  alias Detectino.Api
  alias DetectinoPanel.Components, as: MyComponents
  alias Scenic.{Graph}

  require Logger

  @max_elements 8
  @graph Graph.build()

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  defmodule State do
    @moduledoc false
    defstruct graph: nil, rq_ref: nil, run_ref: nil
  end

  def init(_, _) do
    %{ref: ref} = Api.async_get_scenarios()

    {:ok, %State{graph: @graph, rq_ref: ref}, push: @graph}
  end

  def handle_info({ref, {:ok, scenarios}}, %{rq_ref: rq_ref} = state) when ref == rq_ref do
    handle_scenarios(scenarios, state)
  end

  def handle_info({ref, {:error, err}}, %{rq_ref: rq_ref} = state) when ref == rq_ref do
    messages = ["Cannot fetch!", "Error: #{err}"]
    send_event({:alert_message, :error, messages, true})

    {:noreply, state}
  end

  def handle_info({ref, :ok}, %{run_ref: run_ref} = state) when ref == run_ref do
    Logger.debug("Got ok response from run scenario")
    send_event({:alert_message, :info, "Scenario activated!", true})

    {:noreply, state}
  end

  def handle_info({ref, {:error, err}}, %{run_ref: run_ref} = state) when ref == run_ref do
    Logger.warn("Got err #{inspect(err)} response from run scenario")
    messages = ["Scenario error:", "#{err}"]
    send_event({:alert_message, :error, messages, true})

    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _, :normal}, %{rq_ref: rq_ref} = state)
      when ref == rq_ref do
    {:noreply, %{state | rq_ref: nil}}
  end

  def handle_info({:DOWN, ref, :process, _, :normal}, %{run_ref: run_ref} = state)
      when ref == run_ref do
    {:noreply, %{state | run_ref: nil}}
  end

  def handle_info(msg, state) do
    Logger.debug("Got unhandled info msg: #{inspect(msg)}")

    {:noreply, state}
  end

  def filter_event({:run_scenario, id}, _from, state) do
    Logger.debug("Asked to run scenario id #{id}")

    %{ref: ref} = Api.async_run_scenario(id)

    {:noreply, %{state | run_ref: ref}}
  end

  def filter_event(event, _from, state) do
    {:cont, event, state}
  end

  defp handle_scenarios(scenarios, state) do
    g = Graph.build()

    font_size = 42
    start_x = 5
    start_y = 5

    {g, _, _, _} =
      scenarios
      |> filter_scenarios()
      |> sort_scenarios()
      |> Enum.take(@max_elements)
      |> Enum.reduce({g, start_x, start_y, 1}, fn %{"id" => id, "name" => name}, {g, x, y, idx} ->
        name = String.slice(name, 0..20)

        g =
          g
          |> MyComponents.add_module(__MODULE__.Item, name,
            width: 400 - start_x * 2,
            height: 100 - start_y * 2,
            font_size: font_size,
            id: id,
            translate: {x, y}
          )

        # poor man 2x4 grid
        case idx do
          v when rem(v, 2) == 0 ->
            {g, start_x, y + 100, v + 1}

          v ->
            {g, x + 400, y, v + 1}
        end
      end)

    {:noreply, %{state | graph: g}, push: g}
  end

  defp filter_scenarios(scenarios) do
    scenarios
    |> Enum.filter(fn %{"enabled" => enabled} ->
      enabled
    end)
  end

  defp sort_scenarios(scenarios) do
    scenarios
    |> Enum.sort(fn %{"name" => name1}, %{"name" => name2} ->
      name1 < name2
    end)
  end
end
