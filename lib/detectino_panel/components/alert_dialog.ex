defmodule DetectinoPanel.Components.AlertDialog do
  @moduledoc false
  use Scenic.Component

  alias Scenic.Cache.Static.Texture
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:rect, 3}, {:group, 3}, {:text, 3}]

  require Logger

  defmodule IconsUtils do
    @moduledoc false

    @base_path :code.priv_dir(:detectino_panel) |> Path.join("/static/images")
    @info_hash Scenic.Cache.Support.Hash.file!(
                 Path.join(@base_path, "information-outline.png"),
                 :sha
               )

    @warn_hash Scenic.Cache.Support.Hash.file!(
                 Path.join(@base_path, "warning.png"),
                 :sha
               )

    @error_hash Scenic.Cache.Support.Hash.file!(
                  Path.join(@base_path, "alert-circle-outline.png"),
                  :sha
                )

    @doc false
    def image_path(:info) do
      :code.priv_dir(:detectino_panel)
      |> Path.join("/static/images")
      |> Path.join("information-outline.png")
    end

    def image_path(:warn) do
      :code.priv_dir(:detectino_panel)
      |> Path.join("/static/images")
      |> Path.join("warning.png")
    end

    def image_path(:error) do
      :code.priv_dir(:detectino_panel)
      |> Path.join("/static/images")
      |> Path.join("alert-circle-outline.png")
    end

    @doc false
    def image_hash(:info) do
      @info_hash
    end

    def image_hash(:warn) do
      @warn_hash
    end

    def image_hash(:error) do
      @error_hash
    end
  end

  @w 400
  @h 240

  @valid_levels [:info, :warn, :error]

  @char_width 12
  @font_size 22

  @doc false
  def verify({level, msg, timeout} = data)
      when level in @valid_levels and (is_bitstring(msg) or is_list(msg)) and
             ((is_integer(timeout) and
                 timeout > 0) or is_boolean(timeout)),
      do: {:ok, data}

  def verify(_), do: :invalid_data

  def init({level, msg, timeout}, _opts) when level in @valid_levels do
    icon_hash = IconsUtils.image_hash(level)
    Texture.load(IconsUtils.image_path(level), icon_hash)

    g =
      Graph.build()
      |> group(
        fn g ->
          g
          |> rect({@w, @h}, fill: :gray)
          |> rect({@w, @h}, stroke: {2, :black})
          |> rect({120, 120}, fill: {:image, icon_hash}, translate: {0, 60})
          |> add_multiline_text(msg)
        end,
        translate: {200, 120}
      )

    maybe_schedule_timeout(timeout)

    {:ok, g, push: g}
  end

  def handle_info(:timeout, state) do
    send_event({:dialog_timeout})

    {:noreply, state}
  end

  defp maybe_schedule_timeout(false), do: :ok

  defp maybe_schedule_timeout(timeout) when is_integer(timeout) do
    Process.send_after(self(), :timeout, timeout)
  end

  defp add_multiline_text(%Graph{} = graph, msg) do
    lines = normalize_text(msg)
    max_chars = floor((400 - 120) / @char_width)
    max_lines = ceil(@h / @font_size)
    nr_of_lines = min(Enum.count(lines), max_lines)
    need_vspace = nr_of_lines * @font_size

    {g, _} =
      lines
      |> Enum.take(max_lines)
      |> Enum.reduce({graph, 0}, fn line, {g, cnt} ->
        line = maybe_ellipsis(line, max_chars)

        y_offset = floor((@h - need_vspace) / 2) + @font_size * cnt

        {g
         |> text("#{line}",
           font: :roboto_mono,
           font_size: @font_size,
           fill: :antique_white,
           text_align: :left_top,
           translate: {120, y_offset}
         ), cnt + 1}
      end)

    g
  end

  defp normalize_text(msg) when is_binary(msg) do
    [String.replace(msg, "\n", "")]
  end

  defp normalize_text(msgs) when is_list(msgs) do
    msgs
    |> Enum.map(fn msg -> normalize_text(msg) |> Enum.at(0) end)
  end

  defp maybe_ellipsis(string, max_chars) do
    case String.length(string) do
      v when v <= max_chars ->
        string

      _ ->
        "#{String.slice(string, 0..max_chars)}..."
    end
  end
end
