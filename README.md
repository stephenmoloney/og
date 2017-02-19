# Óg [![Build Status](https://travis-ci.org/stephenmoloney/og.svg)](https://travis-ci.org/stephenmoloney/og) [![Hex Version](http://img.shields.io/hexpm/v/og.svg?style=flat)](https://hex.pm/packages/og) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/og)

[Óg](http://hexdocs.pm/og/Og.html) is a small collection of logger helper functions.


## Installation

Add óg to your list of dependencies in `mix.exs`:

    def deps, do: [{:og, "~> 0.2"}]


## Summary


`log/1`, `log/2`, `log/3`, `log/4`

- Inspects the data before logging it. For example, this can be helpful for avoiding the `Protocol.UndefinedError`
when logging tuples for example.
- *Optionally* pass the log_level `:debug`, `:info`, `:warn` or `:error` which will respect the
logger `:compile_time_purge_level` configuration setting - defaults to `:debug` when not passed.


`log_r/1`, `log_r/2`

- Performs operations identical to `Og.log/4` but returns the data in it's original form.
- Can be useful when one wants to log some intermediate data in the middle of a series of
data transformations using the `|>` operator.


## Example Usages


#### Og.log/1

    Og.log(String.to_atom("test"))

#### Og.log/3

    Og.log(String.to_atom("test"), __ENV__, :warn)


#### Og.log/4

    Og.log(:test, __ENV__, :info, inspect_opts: [syntax_colors: [atom: :blue]])
    Og.log(String.to_atom("test"), :info, [pretty: :true, syntax_colors: [atom: :green]])

#### Og.log_r/3

    %{first: "john", last: "doe"}
    |> Map.to_list()
    |> Enum.filter( &(&1 === {:first, "john"}))
    |> Og.log_r()
    |> List.last()
    |> Tuple.to_list()
    |> List.last()
    |> Og.log_r(:warn)
    |> String.upcase()


## Acknowledgements

- Thanks to [Björn Rochel](https://github.com/BjRo) for the [Apex library](https://github.com/BjRo/apex) which is
used for pretty formatting the data in the `alog` functions.

## Licence

MIT
