defmodule DetectinoPanel.Components.PinError do
  @moduledoc false
  use Scenic.Component

  alias Scenic.Graph

  import Scenic.Primitives, only: [{:rect, 3}, {:group, 3}, {:text, 3}]

  require Logger

  @w 800
  @h 480

  @graph Graph.build()
         |> rect({@w, @h}, id: :blank, fill: :black)
         |> group(
           fn graph ->
             graph
             |> rect({180, 30}, fill: :red, rotate: 0.78)
             |> rect({180, 30}, fill: :red, rotate: 2.35)
             |> text("PIN ERROR!", fill: :red, translate: {200, 20})
           end,
           translate: {220, 220}
         )

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  def init(_, _) do
    {:ok, @graph, push: @graph}
  end

  @doc false
  def handle_input(_event, _context, state) do
    {:noreply, state}
  end
end
