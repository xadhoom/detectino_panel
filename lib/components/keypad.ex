defmodule DetectinoPanel.Components.Keypad do
  @moduledoc false
  use Scenic.Component

  alias DetectinoPanel.Components
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:rect, 3}]

  require Logger

  @width 380
  @height 480
  @hor_offset 5
  @ver_offset 5

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  def init(_, opts) when is_list(opts) do
    id = opts[:id]

    btn_w = 120
    btn_h = 114

    g =
      Graph.build()
      |> rect({@width, @height}, fill: :white)

    {g, _, _} =
      Enum.reduce(1..12, {g, @hor_offset, @ver_offset}, fn n, {g, x, y} ->
        id = String.to_atom("keypad_#{n}")

        g =
          g
          |> Components.add_to_graph(__MODULE__.Button, to_string(n),
            width: btn_w,
            height: btn_h,
            id: id,
            translate: {x, y}
          )

        {x, y} =
          case rem(n, 3) do
            0 -> {@hor_offset, y + btn_h + @ver_offset}
            _ -> {x + btn_w + @hor_offset, y}
          end

        {g, x, y}
      end)

    push_graph(g)

    {:ok, %{id: id, graph: g}}
  end

  def filter_event({:click, :keypad_10}, _, state) do
    {:continue, {:keypad_click, :cancel}, state}
  end

  def filter_event({:click, :keypad_11}, _, state) do
    {:continue, {:keypad_click, 0}, state}
  end

  def filter_event({:click, :keypad_12}, _, state) do
    {:continue, {:keypad_click, :confirm}, state}
  end

  def filter_event({:click, id}, _, state) do
    "keypad_" <> id = Atom.to_string(id)
    {:continue, {:keypad_click, String.to_integer(id)}, state}
  end
end
