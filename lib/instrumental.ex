#
# The MIT License (MIT)
#
# Copyright (c) 2014 Undead Labs, LLC
#

defmodule Instrumental do
  alias Instrumental.Connection
  alias Instrumental.Protocol
  alias Instrumental.Time

  use Application

  def start(_type, _args) do
    Instrumental.Supervisor.start_link
  end

  def gauge(metric, value, time \\ Time.unix_monotonic) when is_binary(metric) do
    case Protocol.format(:gauge, metric, value, time) do
      {:ok, cmd} ->
        Connection.send_cmd(cmd)
      error -> error
    end
  end

  def increment(metric, value \\ 1, time \\ Time.unix_monotonic) when is_binary(metric) do
    case Protocol.format(:increment, metric, value, time) do
      {:ok, cmd} ->
        Connection.send_cmd(cmd)
      error -> error
    end
  end

  def notice(time \\ Time.unix_monotonic, duration \\ 0, message) when is_binary(message) do
    case Protocol.format(:notice, time, duration, message) do
      {:ok, cmd} ->
        Connection.send_cmd(cmd)
      error -> error
    end
  end

  def time(metric, multiplier \\ 1, timeout \\ :infinity, fun) when is_binary(metric) and is_function(fun) do
    start = :os.system_time(:milli_seconds)
    result =
      try do
        task   = Task.async fn -> fun.() end
        Task.await(task, timeout)
      after
        duration = (:os.system_time(:milli_seconds) - start) / 1000
        gauge(metric, (duration * multiplier), start / 1000)
      end
    result
  end

  def time_ms(metric, timeout \\ :infinity, fun) when is_binary(metric) and is_function(fun) do
    time(metric, 1000, timeout, fun)
  end

  def version do
    version(:application.loaded_applications)
  end
  defp version([{app, _, vsn}|t]) do
    case :application.get_application(__MODULE__) do
      {:ok, ^app} -> List.to_string(vsn)
      _ -> version(t)
    end
  end
end
