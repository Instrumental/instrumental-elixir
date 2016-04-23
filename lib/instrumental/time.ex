defmodule Instrumental.Time do
  @doc """
  Unix timestamp in milliseconds since epoch 1970-01-01.
  """
  @spec unix_monotonic :: integer
  def unix_monotonic do
    {mega, sec, _} = :erlang.now
    mega * 1_000_000 + sec
  end
end
