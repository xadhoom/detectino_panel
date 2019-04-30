defmodule DetectinoPanel.Components.Blank do
  @moduledoc false
  use Scenic.Component

  alias DetectinoPanel.Scene.Helpers.Screensaver
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:rect, 3}]

  require Logger

  @w 800
  @h 480

  @graph Graph.build()
         |> rect({@w, @h}, id: :blank, fill: :black)

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  def init(_, _) do
    {:ok, @graph, push: @graph}
  end

  @doc false
  def handle_input(
        {:cursor_button, {:left, :release, _, _}},
        _context,
        state
      ) do
    Screensaver.signal_screensaver()
    send_event({:blank_click})

    {:noreply, state}
  end

  @doc false
  def handle_input(_event, _context, state) do
    {:noreply, state}
  end
end
