#
# The MIT License (MIT)
#
# Copyright (c) 2014 Undead Labs, LLC
#

defmodule Instrumental.Connection do
  defmodule State do
    defstruct sock: nil, state: nil, queue: []

    @type t :: %{
      sock: pid,
      state: connection_state,
      queue: Array
    }

    @type connection_state :: :hello | :connected | :auth
  end

  alias Instrumental.Protocol
  alias Instrumental.Config

  use GenServer
  require Logger

  @connect_retry 5 * 1000
  @auth_retry 15 * 1000
  @ok "ok\n"

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec send_cmd(binary) :: :ok
  def send_cmd(cmd) when is_binary(cmd) do
    case Config.enabled? do
      true ->
        GenServer.cast(__MODULE__, {:send, cmd})
      false -> :ok
    end
  end

  #
  # GenServer callbacks
  #

  def init([]) do
    if Config.enabled? do
      {:ok, %State{queue: []}, 0}
    else
      :ignore
    end
  end

  def handle_cast({:send, cmd}, %{sock: sock, state: :connected, queue: queue} = state) do
    queue = queue ++ [cmd]
    queue |> Enum.each(fn(queued_cmd) -> :gen_tcp.send(sock, queued_cmd) end)

    {:noreply, %State{sock: sock, state: :connected, queue: []}}
  end
  def handle_cast({:send, cmd}, %{queue: queue} = state) do
    Logger.debug "CAST ACCUMULATE :: #{inspect state}"
    {:noreply, %{state | queue: queue ++ [cmd]}, 0}
  end
  def handle_cast(_, state) do
    {:noreply, state}
  end
  
  def handle_info({:tcp, sock, @ok}, %{sock: sock, state: :hello} = state) do
    case :gen_tcp.send(sock, Protocol.authenticate) do
      :ok ->
        :inet.setopts(sock, [active: :once])
        {:noreply, %{state | state: :auth}}
      {:error, _} ->
        Logger.error "Instrumental authentication failure"
        {:noreply, %{state | state: :auth}, @auth_retry}
    end
  end
  def handle_info({:tcp, sock, @ok}, %{sock: sock, state: :auth} = state) do
    :inet.setopts(sock, [active: :once])
    {:noreply, %{state | state: :connected}}
  end
  def handle_info({:tcp, sock, _}, %{sock: sock} = state) do
    :inet.setopts(sock, [active: :once])
    {:noreply, state}
  end

  def handle_info({:tcp_closed, sock}, %{sock: sock} = state) do
    Logger.warn "Instrumental disconnected"
    {:noreply, %{state | sock: nil, state: nil}, @connect_retry}
  end

  def handle_info(:timeout, %{sock: nil, queue: queue}) do
    Logger.info "Connecting to instrumental"
    case connect() do
      {:ok, sock} ->
        Logger.info "Instrumental connected"
        {:noreply, %State{sock: sock, queue: queue}, 0}
      _error ->
        Logger.error "Failed to connect to instrumental"
        {:noreply, %State{queue: queue}, @connect_retry}
    end
  end
  def handle_info(:timeout, %{sock: sock, state: nil} = state) do
    case :gen_tcp.send(sock, Protocol.hello) do
      :ok ->
        :inet.setopts(sock, [active: :once])
        {:noreply, %{state | sock: sock, state: :hello}}
      {:error, _} ->
        Logger.error "Failed to send hello to instrumental"
        {:noreply, state, @auth_retry}
    end
  end
  def handle_info(:timeout, %{sock: sock, state: :auth} = state) do
    case :gen_tcp.send(sock, Protocol.authenticate) do
      :ok ->
        :inet.setopts(sock, [active: :once])
        {:noreply, %{state | state: :auth}}
      {:error, _} ->
        Logger.error "Failed to authenticate with instrumental"
        {:noreply, state, @auth_retry}
    end
  end

  def terminate(_, %{sock: nil}), do: :ok
  def terminate(_, %{sock: sock}) do
    :gen_tcp.close(sock)
    :ok
  end

  #
  # Private
  #

  defp connect do
    :gen_tcp.connect(Config.host, Config.port,
                      [mode: :binary, packet: 0, active: false, keepalive: true])
  end
end
