defmodule Instrumental.MetricTest do
  alias Instrumental, as: I
  alias Instrumental.Time
  alias Instrumental.Connection
  alias Instrumental.Protocol
  use ExUnit.Case
  Code.require_file "test/test_server.exs"
  require Logger


  # :dbg.tracer
  # :dbg.p self()

  test "sends gauge correctly" do
    {:ok, server} = KVServer.start(1,self)
    {:ok, body} = File.read("test_key")
    Application.put_env(Instrumental.Config.app, :host, "localhost")
    Application.put_env(Instrumental.Config.app, :port, 4040)
    Application.put_env(Instrumental.Config.app, :token, body)
    {:ok, pid} = Connection.start_link
    :timer.sleep(5000)
    hello_msg = receive do
      {:command, msg} -> msg
      _ -> assert false
    end
    Logger.info "after receive #{inspect hello_msg}"
    authenticate_msg = receive do
      {:command, msg} -> msg
      _ -> assert false
    end
    Logger.info "after receive #{inspect authenticate_msg}"
    :timer.sleep(5000)
    Logger.error "====================TEST================================"
    Logger.info "gauge"
    I.gauge("elixir.gauge", 1)
    Logger.info "gauge after"
    bullshit_msg = receive do
      {:command, msg} -> msg
      _ -> assert false
    end
    Logger.info "after receive #{inspect bullshit_msg}"
    gauge_msg = receive do
      {:command, msg} -> msg
      _ -> assert false
    end
    Logger.info "after receive #{inspect gauge_msg}"
    # RegExp = "gauge elixir.gauge 1",
    assert Regex.match?(~r/gauge elixir.gauge 1/, gauge_msg)
    # case re:run(gauge_msg, RegExp) do
    #   {match, Captured} -> assert true
    #   nomatch -> assert false
    # end
    # assert ~r/gauge elixir.gauge 1/.run(gauge_msg)
    :timer.sleep(5000)
  end

  # test "sends increment correctly" do
  #   I.increment("elixir.increment")
  #   :timer.sleep(5000)
  # end

  # test "sends time correctly" do
  #   :ok = I.time("elixir.time", fn -> :timer.sleep(100) end)
  #   :timer.sleep(5000)
  # end

  # test "sends notice correctly" do
  #   :ok = I.notice("elixir test notice")
  #   :timer.sleep(5000)
  # end  
end
