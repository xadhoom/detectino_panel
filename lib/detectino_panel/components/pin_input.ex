defmodule DetectinoPanel.Components.PinInput do
  @moduledoc false
  use Scenic.Component

  alias DetectinoPanel.Components, as: MyComponents
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:rrect, 3}, {:circle, 3}]

  require Logger

  @graph Graph.build()
         |> MyComponents.keypad([], id: :keypad, translate: {420, 0})

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  def init(_, opts) when is_list(opts) do
    id = opts[:id]

    {:ok, %{id: id, graph: @graph, selection: ""}, push: @graph}
  end

  def filter_event({:keypad_click, x}, _, %{graph: g} = state)
      when is_integer(x) do
    new_selection = "#{state.selection}#{x}"

    g =
      case has_input?(g) do
        false ->
          g |> add_input(new_selection)

        true ->
          g |> edit_input(new_selection)
      end

    {:halt, %{state | graph: g, selection: new_selection}, push: g}
  end

  def filter_event({:keypad_click, :cancel}, _, %{graph: g} = state) do
    case has_input?(g) do
      true ->
        {:halt, %{state | graph: @graph, selection: ""}, push: @graph}

      false ->
        {:halt, state}
    end
  end

  def filter_event({:keypad_click, :confirm} = _ev, _, %{selection: sel} = state) do
    Logger.debug(sel)

    {:cont, {:keypad_click, :confirm, sel}, %{state | graph: @graph, selection: ""}, push: @graph}
  end

  def filter_event(ev, _, %{graph: g} = state) do
    case has_input?(g) do
      true -> {:cont, ev, state}
      false -> {:halt, state}
    end
  end

  defp has_input?(g) do
    case Graph.get(g, :pin_input) do
      [] ->
        false

      _ ->
        true
    end
  end

  defp add_input(graph, chars) do
    # 420 / 2 and then - 100
    tx = 110
    ty = 200

    graph
    |> rrect({200, 40, 5}, translate: {tx, ty}, fill: :light_gray, id: :pin_input)
    |> add_input_shadows(chars, {tx, ty})
  end

  defp edit_input(graph, chars) do
    graph
    |> Graph.delete(:digit_shadow)
    |> add_input_shadows(chars, {110, 200})
  end

  defp add_input_shadows(graph, chars, {tx, ty}) do
    chars_count =
      chars
      |> String.length()
      |> case do
        x when x < 7 -> x
        _ -> 7
      end

    Enum.reduce(1..chars_count, graph, fn cnt, g ->
      tx = tx + cnt * 25
      ty = ty + 20

      g
      |> circle(12, fill: :black, translate: {tx, ty}, id: :digit_shadow)
    end)
  end
end
