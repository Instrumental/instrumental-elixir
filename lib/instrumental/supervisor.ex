#
# © 2013-2014 Undead Labs, LLC
#

defmodule Instrumental.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Instrumental.Connection, []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
