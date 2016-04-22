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

  def start_test_server(name, port) do
    Logger.info "start_test_server"
    {status, server} = TestServer.start(name, self, port)
    if status == :ok do
      Logger.info "status was #{status} and server is #{inspect server}!"
      {status, server}
    else
      Logger.info "status was #{status}... trying again"
      :timer.sleep(10) # wait for teardown of previous server
      start_test_server(name, port)
    end
  end

  setup(context) do
    port = TestServer.monotonic_ports
    Logger.debug "PORT #{inspect port}"
    {:ok, server} = start_test_server(context.test, port)
    receive do
      { :started } -> Logger.info "started received"
      _ -> assert false
    end
    Application.put_env(Instrumental.Config.app, :host, "localhost")
    Application.put_env(Instrumental.Config.app, :port, port)
    Application.put_env(Instrumental.Config.app, :token, "test_token")
    {:ok, pid} = Connection.start_link

    #    assert Regex.match?(~r/hello .+/, command), command    
    hello_msg = receive do
      %{command: command, sender: sender, test_pid: self} -> %{command: command, sender: sender, test_pid: self}
      _ -> assert false, "didn't receive hello"
    end

    %{command: command, sender: sender, test_pid: test_pid} = hello_msg
    Logger.debug "RECEIVED #{inspect hello_msg}"
    require IEx
    IEx.pry

    assert self == test_pid
    assert server == sender
    Logger.debug inspect(context)
#    Logger.debug "got message from #{inspect pid}"

    authenticate_msg = receive do
      {:command, msg} -> assert Regex.match?(~r/authenticate .+/, msg), msg
      _ -> assert false
    end

    :ok
  end


  @tag timeout: 2000
  test "sends gauge correctly" do
    I.gauge("elixir.gauge", 1)
    receive do
      {:command, msg} -> assert Regex.match?(~r/gauge elixir.gauge 1/, msg), msg
      _ -> assert false
    end
  end

  # @tag timeout: 2000
  # test "sends increment correctly" do
  #   I.increment("elixir.increment")
  #   receive do
  #     {:command, msg} -> assert Regex.match?(~r/increment elixir.increment 1/, msg), msg
  #     _ -> assert false
  #   end
  # end

  # @tag timeout: 2000
  # test "sends time correctly" do
  #   I.time("elixir.time", fn -> :timer.sleep(100) end)
  #   # expecting the time to be something between 0.100 and 0.109
  #   receive do
  #     {:command, msg} -> assert Regex.match?(~r/gauge elixir.time 0.10/, msg), msg
  #     _ -> assert false
  #   end
  # end

  # @tag timeout: 2000
  # test "sends notice correctly" do
  #   I.notice("elixir test notice")
  #   msg = receive do
  #     {:command, msg} -> msg
  #     _ -> assert false
  #   end
  #   assert Regex.match?(~r/^notice/, msg), msg
  #   assert Regex.match?(~r/elixir test notice$/, msg), msg
  # end
end
