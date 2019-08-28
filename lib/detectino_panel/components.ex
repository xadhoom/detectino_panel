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

  def pin_error(graph, title, options \\ [])

  def pin_error(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.PinError, data, options)
  end

  def pin_error(%Primitive{module: SceneRef} = p, data, options) do
    modify(p, __MODULE__.PinError, data, options)
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

  def add_module(graph, module, data \\ [], options \\ [])

  def add_module(%Graph{} = g, module, data, options) do
    add_to_graph(g, module, data, options)
  end

  def add_to_graph(%Graph{} = g, mod, data, options) do
    mod.verify!(data)
    mod.add_to_graph(g, data, options)
  end

  def modify(%Primitive{module: SceneRef} = p, mod, data, options) do
    mod.verify!(data)
    Primitive.put(p, {mod, data}, options)
  end

  def top_bar(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.TopBar, data, options)
  end

  def clock(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.Clock, data, options)
  end

  def scenario_button(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.ScenarioButton, data, options)
  end

  def lock_button(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.LockButton, data, options)
  end

  def event_button(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.EventButton, data, options)
  end

  def intrusion_menu(%Graph{} = g, data, options) do
    add_to_graph(g, __MODULE__.IntrusionMenu, data, options)
  end
end
