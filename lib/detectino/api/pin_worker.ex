defmodule Detectino.Api.PinWorker do
  @moduledoc """
  Listens for PIN check requests and send back a response
  """
  use GenServer

  alias Detectino.Api.{AuthWorker, Pin}

  require Logger

  defmodule State do
    @moduledoc false
    defstruct pin: nil, tref: nil
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: name())
  end

  def get_pin do
    GenServer.call(name(), {:get_pin})
  end

  defp name do
    {:via, Registry, {Registry.DetectinoApi, :pin_api}}
  end

  def init(_) do
    Logger.info("Started pin worker")

    {:ok, %State{}}
  end

  def handle_call({:get_pin}, _from, %{pin: pin} = state) do
    {:reply, pin, state}
  end

  def handle_info({:check_pin, pin, caller}, state) do
    AuthWorker.get_token()
    |> check_pin_impl(pin, caller)

    {:noreply, state}
  end

  def handle_info({:pin_expire}, state) do
    Logger.info("Pin expired")

    {:noreply, %{state | pin: nil}}
  end

  def handle_info({_ref, {:got_valid_pin, pin, expires}}, state)
      when is_integer(expires) do
    Logger.info("Storing valid pin with #{expires}msec expire")

    maybe_cancel_pin_timer(state)

    tref = Process.send_after(self(), {:pin_expire}, expires)

    {:noreply, %{state | pin: pin, tref: tref}}
  end

  def handle_info({_ref, {:got_invalid_pin}}, state) do
    Logger.info("Invalid pin, deleteting from state")

    maybe_cancel_pin_timer(state)

    {:noreply, %{state | pin: nil}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp check_pin_impl(nil, _pin, caller) do
    send(caller, {:check_pin_response, {:error, :unauthorized}})
  end

  defp check_pin_impl(token, pin, caller) when is_binary(token) do
    Task.async(fn ->
      res = Pin.check_pin(token, pin)
      notify_caller(res, caller)
      maybe_store_pin(res, pin)
    end)
  end

  defp maybe_store_pin({:ok, expires}, pin), do: {:got_valid_pin, pin, expires}

  defp maybe_store_pin(_, _), do: {:got_invalid_pin}

  defp notify_caller({:ok, _expires}, caller), do: send(caller, {:check_pin_response, :ok})
  defp notify_caller(res, caller), do: send(caller, {:check_pin_response, res})

  defp maybe_cancel_pin_timer(%{tref: nil}), do: :ok

  defp maybe_cancel_pin_timer(%{tref: t}) when is_reference(t) do
    Process.cancel_timer(t)
  end
end
