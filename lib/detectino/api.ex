defmodule Detectino.Api do
  @moduledoc """
  APIs entry point for interaction with detectino server from panel
  """
  alias Detectino.Api.{AuthWorker, PinWorker, Scenario}

  @doc """
  Performs a pin check to detectino server, asyncronously.
  The caller process will receive a message:
  {:check_pin_response, :ok} or {:check_pin_response, {:error, atom}}
  when the check is completed.
  """
  def check_pin(pin) when is_binary(pin) do
    case get_pin_worker() do
      {:ok, pid} ->
        send(pid, {:check_pin, pin, self()})
        :ok

      {:error, :not_found} ->
        {:error, :unauthorized}
    end
  end

  def get_scenarios do
    {AuthWorker.get_token(), PinWorker.get_pin()}
    |> Scenario.get_available()
  end

  def async_get_scenarios do
    Task.async(fn ->
      get_scenarios()
    end)
  end

  def run_scenario(id) do
    {AuthWorker.get_token(), PinWorker.get_pin()}
    |> Scenario.run(id)
  end

  def async_run_scenario(id) do
    Task.async(fn ->
      run_scenario(id)
    end)
  end

  defp get_pin_worker do
    case Registry.lookup(Registry.DetectinoApi, :pin_api) do
      [{pid, _}] -> {:ok, pid}
      _ -> {:error, :not_found}
    end
  end
end
