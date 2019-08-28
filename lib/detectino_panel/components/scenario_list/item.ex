defmodule DetectinoPanel.Components.ScenarioList.Item do
  @moduledoc false
  use Scenic.Component, has_children: false

  alias Scenic.Graph
  alias Scenic.Primitive

  import Scenic.Primitives, only: [{:rrect, 3}, {:text, 3}]

  @radius 5

  @stroke_color {2, :gray}
  @pressed_color :dark_gray

  @doc false
  def verify(text) when is_bitstring(text), do: {:ok, text}
  def verify(_), do: :invalid_data

  @doc false
  def init(text, opts) when is_bitstring(text) and is_list(opts) do
    id = opts[:id]
    styles = opts[:styles]
    width = styles.width
    height = styles.height
    font_size = styles.font_size

    # build the graph
    graph =
      Graph.build()
      |> rrect({width, height, @radius},
        id: :scenario_item,
        stroke: @stroke_color
      )
      |> add_text(text, font_size, {width, height})

    state = %{
      graph: graph,
      pressed: false,
      id: id
    }

    {:ok, state, push: graph}
  end

  @doc false
  def handle_input({:cursor_button, {:left, :press, _, _}}, _context, state) do
    send_event(:app_interaction)

    state =
      state
      |> Map.put(:pressed, true)

    g = update_color(state)

    {:noreply, state, push: g}
  end

  @doc false
  def handle_input(
        {:cursor_button, {:left, :release, _, _}},
        _context,
        %{pressed: pressed, id: id} = state
      ) do
    send_event(:app_interaction)

    state = Map.put(state, :pressed, false)
    g = update_color(state)

    if pressed do
      send_event({:run_scenario, id})
    end

    {:noreply, state, push: g}
  end

  @doc false
  def handle_input(_event, _context, state) do
    {:noreply, state}
  end

  defp update_color(%{graph: graph, pressed: false}) do
    graph
    |> Graph.modify(:scenario_item, fn p ->
      p
      |> Primitive.put_style(:stroke, @stroke_color)
    end)
  end

  defp update_color(%{graph: graph, pressed: true}) do
    graph
    |> Graph.modify(:scenario_item, fn p ->
      p
      |> Primitive.put_style(:fill, @pressed_color)
    end)
  end

  defp add_text(g, string, font_size, {w, h}) do
    g
    |> text(string,
      fill: :dark_gray,
      text_align: :center_middle,
      font_size: font_size,
      translate: {w / 2, h / 2}
    )
  end
end
