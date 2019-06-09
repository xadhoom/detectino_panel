defmodule Detectino.Api.Events do
  @moduledoc """
  Event pub/sub module, mainly used to interface API with GUI
  """
  alias Registry.DetectinoEvents

  def subscribe(:timer, mf \\ nil) do
    Registry.register(DetectinoEvents, :timer, mf)
  end

  def dispatch_async(event, data) do
    caller = self()

    Task.start_link(fn ->
      dispatch(event, data)
      Process.unlink(caller)
    end)
  end

  def dispatch(event_type, data) when is_atom(event_type) do
    Registry.dispatch(DetectinoEvents, event_type, fn subscribers ->
      subscribers
      |> Enum.each(fn
        {_pid, {m, f}} when is_atom(m) and is_atom(f) ->
          apply(m, f, [{event_type, data}])

        {pid, _} ->
          send(pid, {event_type, data})
      end)
    end)
  end
end
