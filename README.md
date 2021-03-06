**This is a fork and you should not depend on it yet. Check the original repo for the capabilities of the package in hex.**

# Instrumental Elixir Agent

Instrumental is a [application monitoring platform](https://instrumentalapp.com) built for developers who want a better understanding of their production software. Powerful tools, like the [Instrumental Query Language](https://instrumentalapp.com/docs/query-language), combined with an exploration-focused interface allow you to get real answers to complex questions, in real-time.

This agent supports custom metric monitoring for Elixir applications. It provides high-data reliability at high scale, without ever blocking your process or causing an exception. 

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

Add an Instrumental config option and a value for token in your `config.exs`

```elixir
config :instrumental,
  token: "mytoken"
```

### Options

  * token (required) - api key for authenticating with Instrumental
  * host (optional) - host of Instrumental collector, *default: collector.instrumentalapp.com*
  * port (optional) - port of Instrumental collector, *default: 8000*


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


### Functions

```elixir
# increments
Instrumental.increment("metric.name");

# gauges
Instrumental.gauge("metric.name", 82.12);

# notices
Instrumental.notice("An event occurred");

# timing a function (in seconds)
Instrumental.time("metric.name", &Something.function/0);
Instrumental.time("metric.name", fn -> Something.function(arg1) end)

# timing a function (in milliseconds)
Instrumental.time_ms("metric.name", &Something.function/0);
Instrumental.time_ms("metric.name", fn -> Something.function(arg1) end)

```

## Authors

* Jamie Winsor (<jamie@undeadlabs.com>)
* Joel Meador
* Elijah Miller
* Matthew Gordon
