# Óg [![Build Status](https://travis-ci.org/stephenmoloney/og.svg)](https://travis-ci.org/stephenmoloney/og) [![Hex Version](http://img.shields.io/hexpm/v/og.svg?style=flat)](https://hex.pm/packages/og) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/og)

[Óg](http://hexdocs.pm/og/Og.html) is a small collection of debugging helper functions.
Og is a debugging tool for development environments.


## Note:

- Do not use release versions of `Og` less than 1.0 due to a security issue with
the use of `Code.eval_string/3`. Read [more in the changelog](https://github.com/stephenmoloney/og/blob/master/CHANGELOG.md#v024).
- Functions `Og.log/2` and `Og.log_r/2` are debugging tools for use during development only.


## Installation

Add óg to your list of dependencies in `mix.exs`:

    def deps, do: [{:og, "~> 1.0"}]

Ensure that `:logger` is started in the applications:

    `def application do [applications: [:logger]] end`

## Summary

- `log/2` - logs the data transformed by the inspector function
and returns `:ok`
- `log_r/2` - logs the data transformed by the inspector function
and returns the original data.


- Inspection of the data before logging it can be helpful in a debugging context for
    1. Avoiding the `Protocol.UndefinedError` when logging tuples for example.
    2. Not needing to require Logger


- However, the functions `Og.log` and `Og.log_r` should be reserved for
debugging code only in `:dev` environments and should not
 be used in production because:
    - Formatting the data carries an overhead.


There are two choices of inspector functions for formatting the data:
    1. [inspector: :kernel] - `&Kernel.inspect/2` (from erlang core and the default)
    2. [inspector: :apex] - `&Apex.Format.format/2` from [Apex](https://hex.pm/packages/apex) library for pretty printing


## Example usage

  - optional configuration in `config.exs`
```elixir
config :logger, :og,
  kernel_opts: [width: 70],
  apex_opts: [numbers: :false, color: :false]
```

  - some examples
```elixir

# Basic logging
Og.log(:test)

# Logging at the `:warn` level
Og.log(:test, level: :warn)

# Logging at the `:warn` level and with __ENV__ specified to get richer information
Og.log(:test, level: :warn, env: __ENV__)

# Logging with the Apex inspector
Og.log(:test, inspector: :apex)

#### Logging inside a chain of piped functions
defmodule OgTest do
  def log() do
    %{first: "john", last: "doe"}
    |> Map.to_list()
    |> Enum.filter( &(&1 === {:first, "john"}))
    |> Og.log_r()
    |> List.last()
    |> Tuple.to_list()
    |> List.last()
    |> Og.log_r(env: __ENV__, inspector: :kernel, level: :info)
    |> String.upcase()
  end
end
OgTest.log()
```


## Acknowledgements

- Credit to [Björn Rochel](https://github.com/BjRo) for the [Apex library](https://github.com/BjRo/apex).
Setting opts to `[inspector: :apex]` will use the `Apex.Format.format/2` function from the apex library.

## Todo

- [ ] Investigate adding a custom formatting module as an optional additional means of logging.

## Licence

MIT
