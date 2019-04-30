defmodule DetectinoPanel.Components.Keypad.Button do
  @moduledoc false
  use Scenic.Component, has_children: false

  alias DetectinoPanel.Scene.Helpers.Screensaver
  alias Scenic.Graph
  alias Scenic.Primitive
  alias Scenic.ViewPort

  import Scenic.Primitives, only: [{:rrect, 3}, {:text, 3}]

  @radius 5

  @color :light_gray
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

    # build the graph
    graph =
      Graph.build()
      |> rrect({width, height, @radius},
        id: :keypad_btn,
        fill: @color
      )
      |> add_text(text, {width, height})

    state = %{
      graph: graph,
      pressed: false,
      id: id
    }

    {:ok, state, push: graph}
  end

  @doc false
  def handle_input({:cursor_button, {:left, :press, _, _}}, context, state) do
    Screensaver.signal_screensaver()

    state =
      state
      |> Map.put(:pressed, true)

    g = update_color(state)

    ViewPort.capture_input(context, [:cursor_button, :cursor_pos])

    {:noreply, state, push: g}
  end

  @doc false
  def handle_input(
        {:cursor_button, {:left, :release, _, _}},
        context,
        %{pressed: pressed, id: id} = state
      ) do
    state = Map.put(state, :pressed, false)
    g = update_color(state)

    ViewPort.release_input(context, [:cursor_button, :cursor_pos])

    if pressed do
      send_event({:click, id})
    end

    {:noreply, state, push: g}
  end

  @doc false
  def handle_input(_event, _context, state) do
    {:noreply, state}
  end

  defp update_color(%{graph: graph, pressed: false}) do
    graph
    |> Graph.modify(:keypad_btn, fn p ->
      p
      |> Primitive.put_style(:fill, @color)
    end)
  end

  defp update_color(%{graph: graph, pressed: true}) do
    graph
    |> Graph.modify(:keypad_btn, fn p ->
      p
      |> Primitive.put_style(:fill, @pressed_color)
    end)
  end

  defp add_text(g, n, {w, h}) do
    g
    |> text(label(n),
      fill: :dark_gray,
      text_align: :center_middle,
      font_size: 64,
      translate: {w / 2, h / 2}
    )
  end

  defp label("10"), do: "X"

  defp label("11"), do: "0"

  defp label("12"), do: "OK"

  defp label(label), do: label
end
