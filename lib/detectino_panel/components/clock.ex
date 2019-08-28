defmodule DetectinoPanel.Components.Clock do
  @moduledoc false
  use Scenic.Component

  alias Detectino.Api.Events
  alias Scenic.{Graph, Scene, ViewPort}

  import Scenic.Primitives

  @graph Graph.build()

  defmodule State do
    @moduledoc false
    defstruct graph: nil
  end

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  def init(_opts, _) do
    Events.subscribe(:timer)

    {:ok, %State{graph: @graph}, push: @graph}
  end

  def handle_info({:timer, current_dt}, state) do
    g =
      @graph
      |> text(format_dt(current_dt),
        fill: :antique_white,
        text_align: :left_middle,
        font_size: 16,
        translate: {0, 10}
      )

    {:noreply, %{state | graph: g}, push: g}
  end

  defp format_dt(dt) do
    Timex.format!(dt, " %H:%M:%S %A, %B %-d %Y", :strftime)
  end
end
