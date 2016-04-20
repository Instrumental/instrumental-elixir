defmodule Instrumental.MetricTest do
  alias Instrumental, as: I
  alias Instrumental.Time
  alias Instrumental.Connection
  alias Instrumental.Protocol
  use ExUnit.Case



  # {:ok, cmd} = Protocol.format(:gauge, "elixir.gauge", 1, Time.unix_monotonic)
  # :ok = Connection.send_cmd(cmd)
  # Connection.handle_cast({:send, cmd}, Connection.State{sock: pid, })
  # :timer.sleep(5000)
  # :ok = Connection.send_cmd(cmd)
  # {:ok, cmd} = Protocol.format(:gauge, "elixir.gauge", 1, Time.unix_monotonic)
  # state = %Connection.State{state: :connected}
  # I.Connection.hand_cast({:send, cmd}, state)

  # :dbg.tracer
  # :dbg.p self()

  
  test "sends gauge correctly" do
    # :dbg.tracer
    # :dbg.p self()
    {:ok, body} = File.read("test_key")
    Application.put_env(Instrumental.Config.app, :token, body)
    {:ok, pid} = Connection.start_link
    :timer.sleep(5000)
    I.gauge("elixir.gauge", 1)
    :timer.sleep(5000)
  end

  test "sends increment correctly" do
    {:ok, body} = File.read("test_key")
    Application.put_env(Instrumental.Config.app, :token, body)
    {:ok, pid} = Connection.start_link
    :timer.sleep(5000)
    I.increment("elixir.increment")
    :timer.sleep(5000)
  end

  test "sends time correctly" do
    {:ok, body} = File.read("test_key")
    Application.put_env(Instrumental.Config.app, :token, body)
    {:ok, pid} = Connection.start_link
    :timer.sleep(5000)
    :ok = I.time("elixir.time", fn -> :timer.sleep(100) end)
    :timer.sleep(5000)
  end

  test "sends notice correctly" do
    {:ok, body} = File.read("test_key")
    Application.put_env(Instrumental.Config.app, :token, body)
    {:ok, pid} = Connection.start_link
    :timer.sleep(5000)
    :ok = I.notice("elixir test notice")
    :timer.sleep(5000)
  end  
end
