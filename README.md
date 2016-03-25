# Instrumental

An Elixir client for [Instrumental](http://instrumentalapp.com)

## Requirements

* Elixir ~> 1.0

## Installation

Add Instrumental as a dependency in your `mix.exs` file

```elixir
def application do
  [applications: [:instrumental]]
end

defp deps do
  [
    {:instrumental, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get` in your shell to fetch the dependencies.

## Configuration

Add an instrumental config option and a value for token in your `config.exs`

```elixir
config :instrumental,
  token: "mytoken"
```

### Options

  * token (required) - api key for authenticating with instrumental
  * host (optional) - host of instrumental collector, *default: collector.instrumentalapp.com*
  * port (optional) - port of instrumental collector, *default: 8000*


## Usage

```elixir
defmodule ImportantThing do
  alias Instrumental, as: I

  def compute_important_thing do
    # tell Instrumental how long it takes to run a
    # computation so we can know if our performance
    # is changing over time.
    value = I.time("ImportantThing.timing", &ImportantThing.compute/0)
    # tell Instrumental a value that was computed so we
    # can track its change over time
    I.gauge("ImportantThing.value", value)
    value
  end

  def compute do
    # tell Instrumental we computed a value so we can know
    # how often that is happening.
    I.increment("ImportantThing.computed")

    # do some hard stuff here
  end
end

```

* `alias` optional :smiley:


## Authors

* Jamie Winsor (<jamie@undeadlabs.com>)
