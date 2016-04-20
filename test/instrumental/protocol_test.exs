defmodule Instrumental.ProtocolTest do
  alias Instrumental.Protocol
  alias Instrumental.Time

  use ExUnit.Case

  test "format/4 formatting a valid increment message" do
    metric     = "test-metric"
    value      = 1
    time       = Time.unix_monotonic
    {:ok, msg} = Protocol.format(:increment, metric, value, time)

    assert msg == "increment #{metric} #{value} #{time}\n"
  end

  test "format/4 formatting a valid gauage message" do
    metric     = "test-metric"
    value      = 1
    time       = Time.unix_monotonic
    {:ok, msg} = Protocol.format(:gauge, metric, value, time)

    assert msg == "gauge #{metric} #{value} #{time}\n"
  end

  test "format/4 formatting for invalid metrics" do
    metric     = "bad metric"
    value      = 1
    time       = Time.unix_monotonic
    {:error, :invalid_metric} = Protocol.format(:gauge, "", value, time)
    {:error, :invalid_metric} = Protocol.format(:gauge, "bad metric", value, time)
    {:error, :invalid_metric} = Protocol.format(:gauge, " badmetric", value, time)
    {:error, :invalid_metric} = Protocol.format(:gauge, "badmetric ", value, time)
    {:error, :invalid_metric} = Protocol.format(:gauge, "b(admetric", value, time)
  end

  test "format/4 formatting for valid notice" do
    duration   = 1
    time       = Time.unix_monotonic
    message    = "hello world!"
    {:ok, msg} = Protocol.format(:notice, time, duration, message)

    assert msg == "notice #{time} #{duration} #{message}\n"
  end

  test "format/4 formatting for invalid notices" do
    duration   = 1
    time       = Time.unix_monotonic
    {:error, :invalid_notice} = Protocol.format(:notice, time, duration, "new\nline")
    {:error, :invalid_notice} = Protocol.format(:notice, time, duration, "new\rline")
  end
end
