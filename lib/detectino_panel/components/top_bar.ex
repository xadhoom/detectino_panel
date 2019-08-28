defmodule DetectinoPanel.Components.TopBar do
  @moduledoc false
  use Scenic.Component

  alias Detectino.Api.Events
  alias DetectinoPanel.Components, as: MyComponents
  alias Scenic.{Graph, Scene, ViewPort}

  import Scenic.Primitives

  @graph Graph.build()
         |> rectangle({800, 80}, fill: :red)
         |> MyComponents.clock([], id: :top_bar)

  defmodule State do
    @moduledoc false
    defstruct graph: nil
  end

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  def init(_opts, _) do
    {:ok, %State{graph: @graph}, push: @graph}
  end
end
