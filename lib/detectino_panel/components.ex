defmodule DetectinoPanel.Components do
  @moduledoc false

  alias Scenic.Graph
  alias Scenic.Primitive

  def keypad(graph, title, options \\ [])

  def keypad(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.Keypad, data, options)
  end

  def keypad(%Primitive{module: SceneRef} = p, data, options) do
    modify(p, __MODULE__.Keypad, data, options)
  end

  def background(graph, title, options \\ [])

  def background(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.Background, data, options)
  end

  def background(%Primitive{module: SceneRef} = p, data, options) do
    modify(p, __MODULE__.Background, data, options)
  end

  def pin_input(graph, title, options \\ [])

  def pin_input(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.PinInput, data, options)
  end

  def pin_input(%Primitive{module: SceneRef} = p, data, options) do
    modify(p, __MODULE__.PinInput, data, options)
  end

  def blank(graph, title, options \\ [])

  def blank(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.Blank, data, options)
  end

  def blank(%Primitive{module: SceneRef} = p, data, options) do
    modify(p, __MODULE__.Blank, data, options)
  end

  def add_to_graph(%Graph{} = g, mod, data, options) do
    mod.verify!(data)
    mod.add_to_graph(g, data, options)
  end

  def modify(%Primitive{module: SceneRef} = p, mod, data, options) do
    mod.verify!(data)
    Primitive.put(p, {mod, data}, options)
  end
end
