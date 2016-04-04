# Óg [![Build Status](https://travis-ci.org/stephenmoloney/og.svg)](https://travis-ci.org/stephenmoloney/og) [![Hex Version](http://img.shields.io/hexpm/v/og.svg?style=flat)](https://hex.pm/packages/og) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/og)

[Óg](http://hexdocs.pm/og/Og.html) is a small collection of logger helper functions in elixir.


## Installation

Add óg to your list of dependencies in `mix.exs`:

    def deps, do: [{:og, "~> 0.0.5"}]


## Summary


`log/1`, `log/2`, `log/3`, `log/4`

- Inspects the data before logging it. For example, this can be helpful for avoiding the `Protocol.UndefinedError`
when logging tuples for example.
- *Optionally* pass the  `__ENV__` environment variable to log the module, line and function, thereby,
being able to identify exactly where the log was made.
- *Optionally* pass the log_level `:debug`, `:info`, `:warn` or `:error` which will respect the
logger `:compile_time_purge_level` configuration setting.
- *Optionally* pass the inspect_opts argument to customise the inspect options in the `Kernel.inspect/2`
function. see also `Inspect.Opts`.


`log_return/1`, `log_return/2`, `log_return/3`, `log_return/4`

- Performs operations identical to `Og.log/4` but returns the data in it's original form.
- The same options apply as for the `log` functions.
- Can be useful when one wants to log some intermediate data in the middle of a series of
data transformations using the `|>` operator. see the example in `log_return/3` or `log_return/4`.


`context/1`, `context/2`, `context/3`

- Logs the environment details passed as the `__ENV__` argument by the caller. Shows the
module, function, function arity and line number from where the call was made.
- Can be useful when one wants to identify the most recent function call when debugging
and within a sequence of function calls prior to an exception or error.


`conn_context/2`, `conn_context/3`, `conn_context/4`, `conn_context/5`

- Logs the environment details passed as the `__ENV__` argument by the caller. Shows the
module, function, function arity and line number from where the call was made.
- Logs details about the conn struct. The key-value pairs are returned for the keys passed in
the conn_fields list.
- Can be useful when one wants to log specific data within the conn struct and the module,
function and line environment information.


## Example Usages

#### Og.log/1

    Og.log(String.to_atom("test"))


#### Og.log/3

    Og.log(String.to_atom("test"), __ENV__, :warn)


#### Og.log_return/3

    %{first: "john", last: "doe"}
    |> Map.to_list()
    |> Enum.filter( &(&1 === {:first, "john"}))
    |> Og.log_return()
    |> List.last()
    |> Tuple.to_list()
    |> List.last()
    |> Og.log_return(:warn)
    |> String.upcase()


#### Og.context/3

    defmodule Test do
      def env_test() do
        Og.context(__ENV__, :info)
      end
    end

    Test.env_test()


#### Og.conn_context/3

    defmodule Test do
      use Plug.Test
      def test() do
        conn = Plug.Test.conn(:get, "/test", :nil)
        Og.conn_context(conn, __ENV__, :debug)
      end
    end

    Test.test()


## Licence

MIT
