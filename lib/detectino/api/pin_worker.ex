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

  def handle_call({:check_pin, pin}, _f, state) do
    res =
      AuthWorker.get_token()
      |> check_pin_impl(pin)

    {:reply, res, state}
  end

  defp check_pin_impl(nil, _pin) do
    {:error, :unauthorized}
  end

  defp check_pin_impl(token, pin) when is_binary(token) do
    Pin.check_pin(token, pin)
  end
end
