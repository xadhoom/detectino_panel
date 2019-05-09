defmodule Detectino.Api.Supervisor do
  @moduledoc false
  use Supervisor

  alias Detectino.Api.AuthWorker

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec start_child(:supervisor.child_spec() | {module(), term()} | module() | [term()]) ::
          Supervisor.on_start_child()
  def start_child(child_spec) do
    Supervisor.start_child(__MODULE__, child_spec)
  end

  def start_websocket(args) do
    alias Detectino.Api.Websocket

    {Websocket, args}
    |> start_child()
  end

  @impl true
  def init(_args) do
    children = [
      {AuthWorker, []}
    ]

    Supervisor.init(children, strategy: :one_for_all, max_restarts: 5, max_seconds: 3)
  end
end
