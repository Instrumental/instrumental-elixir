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

  def start_test_server do
    Logger.info "start_test_server"
    {status, server} = TestServer.start(1, self)
    if status == :ok do
      Logger.info "status was #{status}!"
      {status, server}
    else
      Logger.info "status was #{status}... trying again"
      :timer.sleep(10) # wait for teardown of previous server
      start_test_server()
    end
  end

  setup do
    {:ok, server} = start_test_server()
    receive do
      { :started } -> Logger.info "started received"
      _ -> assert false
    end
    Application.put_env(Instrumental.Config.app, :host, "localhost")
    Application.put_env(Instrumental.Config.app, :port, 4040)
    Application.put_env(Instrumental.Config.app, :token, "test_token")
    {:ok, pid} = Connection.start_link

    hello_msg = receive do
      {:command, msg} -> assert Regex.match?(~r/hello .+/, msg)
      _ -> assert false
    end

    authenticate_msg = receive do
      {:command, msg} -> assert Regex.match?(~r/authenticate .+/, msg)
      _ -> assert false
    end

    :ok
  end


  @tag timeout: 2000
  test "sends gauge correctly" do
    I.gauge("elixir.gauge", 1)
    receive do
      {:command, msg} -> assert Regex.match?(~r/gauge elixir.gauge 1/, msg)
      _ -> assert false
    end
  end

  @tag timeout: 2000
  test "sends increment correctly" do
    I.increment("elixir.increment")
    receive do
      {:command, msg} -> assert Regex.match?(~r/increment elixir.increment 1/, msg)
      _ -> assert false
    end
  end

  test "sends time correctly" do
    I.time("elixir.time", fn -> :timer.sleep(100) end)
    # expecting the time to be something between 0.100 and 0.109
    receive do
      {:command, msg} -> assert Regex.match?(~r/gauge elixir.time 0.10/, msg)
      _ -> assert false
    end
  end

  test "sends notice correctly" do
    I.notice("elixir test notice")
    notice_msg = receive do
      {:command, msg} -> msg
      _ -> assert false
    end
    assert Regex.match?(~r/^notice/, notice_msg)
    assert Regex.match?(~r/elixir test notice$/, notice_msg)
  end
end
