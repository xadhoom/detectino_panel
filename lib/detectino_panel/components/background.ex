defmodule DetectinoPanel.Components.Background do
  @moduledoc false
  use Scenic.Component

  alias Scenic.Cache.Static.Texture
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:rect, 3}]

  require Logger

  @sea_path :code.priv_dir(:detectino_panel)
            |> Path.join("/static/images/sea.png")
  @sea_hash Scenic.Cache.Support.Hash.file!(@sea_path, :sha)

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
    {:ok, _hash} = Scenic.Cache.Support.File.read(path, @sea_hash)

    # TODO: should not be needed to be global
    Texture.load(path, @sea_hash, scope: :global)

    {:ok, @graph, push: @graph}
  end

  @doc false
  def handle_input(
        {:cursor_button, {:left, :release, _, _}},
        _context,
        state
      ) do
    send_event({:background_click})

    {:noreply, state}
  end

  @doc false
  def handle_input(_event, _context, state) do
    {:noreply, state}
  end
end
