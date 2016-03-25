defmodule InstrumentalTest do
  use ExUnit.Case#, async: true

  test "time/4 returns the value of the passed function" do
    metric   = "test.metric"
    expected = 42

    assert expected == Instrumental.time(metric, fn -> 42 end)
  end

  test "time_ms/3 returns the value of the passed function" do
    metric   = "test.metric"
    expected = 42

    assert expected == Instrumental.time_ms(metric, fn -> 42 end)
  end
end
