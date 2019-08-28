defmodule DetectinoPanel.Components.EventButton do
  @moduledoc false
  use Scenic.Component

  alias Scenic.Cache.Static.Texture
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:rect, 3}, {:rrect, 3}]

  require Logger

  @image_path :code.priv_dir(:detectino_panel)
              |> Path.join("/static/images/event.png")
  @image_hash Scenic.Cache.Support.Hash.file!(@image_path, :sha)

  @image_width 200
  @image_height 200

  @graph Graph.build()
         |> rect({@image_width, @image_height},
           id: __MODULE__,
           fill: {:image, @image_hash}
         )
         |> rrect({@image_width, @image_height, 5},
           stroke: {2, :gray}
         )

  @doc false
  def verify([]), do: {:ok, []}
  def verify(_), do: :invalid_data

  def init(_, _) do
    path =
      :code.priv_dir(:detectino_panel)
      |> Path.join("/static/images/event.png")

    # cannot use compile time path because it will change from developer dir
    # so use the runtime one, the hash will ensure that the file is the same
    {:ok, _hash} = Scenic.Cache.Support.File.read(path, @image_hash)

    # TODO: should not be needed to be global
    Texture.load(path, @image_hash, scope: :global)

    {:ok, @graph, push: @graph}
  end

  @doc false
  def handle_input(
        {:cursor_button, {:left, :release, _, _}},
        _context,
        state
      ) do
    send_event({:event_click})

    {:noreply, state}
  end

  @doc false
  def handle_input(_event, _context, state) do
    {:noreply, state}
  end
end
