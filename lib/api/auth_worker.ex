defmodule DetectinoPanel.Api.AuthWorker do
  @moduledoc """
  Performs logins and keeps token refreshed.
  Starts websocket worker via DetectinoPanel.Api.Supervisor.
  """
  use GenServer

  alias DetectinoPanel.Api.{Session, Websocket}
  alias DetectinoPanel.Api.Supervisor, as: ApiSup

  require Logger

  defmodule State do
    @moduledoc false

    defstruct token: nil
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    Logger.info("Started auth worker")

    Process.send_after(self(), {:perform_auth}, 1000)

    {:ok, %State{}}
  end

  def handle_info({:perform_auth}, state) do
    case Session.login() do
      {:ok, token} ->
        start_socket(token)
        {:noreply, %{state | token: token}}

      err ->
        Logger.error("Got login error #{inspect(err)}, bailing out...")
        {:stop, :normal, state}
    end
  end

  defp start_socket(token) do
    {:ok, pid} = ApiSup.start_websocket([])
    Process.link(pid)
    {:ok, :connected} = Websocket.connect(pid, token)
  end
end
