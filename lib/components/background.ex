defmodule DetectinoPanel.Components.Background do
  @moduledoc false
  use Scenic.Component

  alias Scenic.Graph

  import Scenic.Primitives, only: [{:rect, 3}]

  require Logger

  @sea_path :code.priv_dir(:detectino_panel)
            |> Path.join("/static/images/sea.png")
  @sea_hash Scenic.Cache.Hash.file!(@sea_path, :sha)

  @sea_width 800
  @sea_height 480

  @graph Graph.build()
         |> rect({@sea_width, @sea_height},
           id: :sea_bground,
           fill: {:image, {@sea_hash, 255}}
         )

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  def init(_, _) do
    path =
      :code.priv_dir(:detectino_panel)
      |> Path.join("/static/images/sea.png")

    # cannot use compile time path because it will change from developer dir
    # so use the runtime one, the hash will ensure that the file is the same
    {:ok, _hash} = Scenic.Cache.File.load(path, @sea_hash)

    push_graph(@graph)

    {:ok, @graph}
  end
end
