defmodule Detectino.Api.Websocket do
  @moduledoc false
  alias Detectino.Api.Events
  alias Phoenix.Channels.GenSocketClient

  require Logger

  @behaviour GenSocketClient

  @otp_app :detectino_panel

  defmodule State do
    @moduledoc false

    defstruct state: :disconnected,
              endpoint: nil,
              caller: nil
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :temporary
    }
  end

  def start_link(opts \\ []) do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      get_ep(opts)
    )
  end

  def connect(server, token) do
    GenSocketClient.call(server, {:connect, token})
  end

  def init(endpoint) do
    Logger.info("Started websocket API worker")

    state = %State{endpoint: endpoint}

    {:noconnect, state.endpoint, [], state}
  end

  def handle_call({:connect, token}, from, _transport, state) do
    send(self(), {:connect, token})

    {:noreply, %{state | caller: from}}
  end

  def handle_info({:connect, token}, _transport, state) do
    {:connect, state.endpoint, [{"guardian_token", token}], state}
  end

  @doc false
  def handle_connected(transport, %{caller: from} = state) do
    Logger.info("websocket connected")

    GenSocketClient.reply(from, {:ok, :connected})

    state = join_api_channels(transport, state)

    {:ok, %{state | state: :connected, caller: nil}}
  end

  @doc false
  def handle_disconnected(reason, %{caller: from} = state) do
    Logger.error("Websocket disconnected: #{inspect(reason)}")

    GenSocketClient.reply(from, {:error, :disconnected})

    {:stop, :disconnected, %{state | state: :disconnected}}
  end

  @doc false
  def handle_disconnected(reason, state) do
    Logger.error("Websocket disconnected: #{inspect(reason)}")

    {:stop, :disconnected, %{state | state: :disconnected}}
  end

  @doc false
  def handle_channel_closed(topic, _payload, _transport, state) do
    Logger.error("Websocket channel #{topic} closed, exiting.")

    {:stop, :disconnected, %{state | state: :disconnected}}
  end

  @doc false
  def handle_joined(topic, payload, _transport, state) do
    Logger.info("Joined topic #{topic}, got payload #{inspect(payload)}")

    {:ok, state}
  end

  @doc false
  def handle_join_error(_topic, _payload, _transport, state) do
    Logger.error("Websocket join error, exiting.")

    {:stop, :error, %{state | state: :disconnected}}
  end

  @doc false
  def handle_message("timer:time", _event, %{"time" => time}, _transport, state) do
    # Logger.debug("Timer event: #{inspect(time)}")
    naive = Timex.parse!(time, "{ISO:Extended}")
    Events.dispatch_async(:timer, naive)

    {:ok, state}
  end

  def handle_message(_topic, _event, _payload, _transport, state) do
    # Logger.debug("#{topic} event #{event}: #{inspect(payload)}")

    {:ok, state}
  end

  @doc false
  def handle_reply(_topic, _ref, _payload, _transport, state) do
    {:ok, state}
  end

  defp get_ep(opts) do
    default_ep = @otp_app |> Application.get_env(:detectino_api) |> Keyword.get(:ws_ep)
    Keyword.get(opts, :endpoint, default_ep)
  end

  defp join_api_channels(transport, state) do
    [
      "timer:time",
      "event:arm",
      "event:alarm",
      "event:alarm_events",
      "event:exit_timer",
      "event:entry_timer"
    ]
    |> Enum.each(fn topic ->
      GenSocketClient.join(transport, topic)
    end)

    state
  end
end
