defmodule TestServer do
  use Application
  require Logger

  @doc false
  def start(_type, test_process) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: TestServer.TaskSupervisor]]),
      worker(Task, [TestServer, :accept, [4040, test_process]])
    ]

    opts = [strategy: :one_for_one, name: TestServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Starts accepting connections on the given `port`.
  """
  def accept(port, test_process) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket, test_process)
  end

  defp loop_acceptor(socket, test_process) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(TestServer.TaskSupervisor,
      fn -> serve(client, test_process) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket, test_process)
  end

  # def send_ok do
  #   write_line("ok\nok\n", socket)
  # end

  defp serve(socket, test_process) do
    command = socket |> read_line()
    Logger.info "COMMAND:: #{inspect command}"

    if Regex.match?(~r/hello/, command) do
      Logger.info "OK"
      write_line("ok\n", socket)
    end

    if Regex.match?(~r/authenticate/, command) do
      Logger.info "OK"
      write_line("ok\n", socket)
    end

    Logger.info "SEND TO TEST"
    send(test_process, {:command, command})

    serve(socket, test_process)
  end

  defp read_line(socket) do
    Logger.error "read line"
    {:ok, data} = :gen_tcp.recv(socket, 0)
    Logger.error "read line after #{inspect data}"
    data
  end

  defp write_line(line, socket) do
    Logger.error "write line"
    :gen_tcp.send(socket, line)
    Logger.error "write line finished"
  end
end
