defmodule Detectino.Api.PinWorker do
  @moduledoc """
  Listens for PIN check requests and send back a response
  """
  use GenServer

  alias Detectino.Api.{AuthWorker, Pin}

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: name())
  end

  defp name do
    {:via, Registry, {Registry.DetectinoApi, :pin_api}}
  end

  def init(_) do
    Logger.info("Started pin worker")

    {:ok, nil}
  end

  def handle_info({:check_pin, pin, caller}, state) do
    AuthWorker.get_token()
    |> check_pin_impl(pin, caller)

    {:noreply, state}
  end

  defp check_pin_impl(nil, _pin, caller) do
    send(caller, {:check_pin_response, {:error, :unauthorized}})
  end

  defp check_pin_impl(token, pin, caller) when is_binary(token) do
    send(caller, {:check_pin_response, Pin.check_pin(token, pin)})
  end
end
