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
    
    Application.put_env(Instrumental.Config.app, :host, "localhost")
    Application.put_env(Instrumental.Config.app, :port, 4040)
    Application.put_env(Instrumental.Config.app, :token, "test_token")
    {:ok, pid} = Connection.start_link

    hello_msg = receive do
      {:command, msg} -> msg
      _ -> assert false
    end

    authenticate_msg = receive do
      {:command, msg} -> msg
      _ -> assert false
    end

    I.gauge("elixir.gauge", 1)
    gauge_msg = receive do
      {:command, msg} -> msg
      _ -> assert false
    end

    assert Regex.match?(~r/gauge elixir.gauge 1/, gauge_msg)
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
