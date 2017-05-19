# Óg [![Build Status](https://travis-ci.org/stephenmoloney/og.svg)](https://travis-ci.org/stephenmoloney/og) [![Hex Version](http://img.shields.io/hexpm/v/og.svg?style=flat)](https://hex.pm/packages/og) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/og)

[Óg](http://hexdocs.pm/og/Og.html) is a small collection of debugging functions for logging data.


### Note

- Functions `Og.log/2` and `Og.log_r/2` are primarily intended as debugging tools.


### Installation

Add óg to your list of dependencies in `mix.exs`:

```elixir
def deps, do: [{:og, "~> 1.0"}]
```

Ensure that `:logger` is started in the applications:

```elixir
def application do [applications: [:logger, :og]] end
```

## Summary

- `log/2` - logs the data transformed by the inspector function
and returns `:ok`


- `log_r/2` - logs the data transformed by the inspector function
and returns the original data.


- Inspection of the data before logging it can be helpful in a debugging context for
example for
    - Avoiding the `Protocol.UndefinedError` when logging tuples.
    - Not needing to require Logger


- Formatting with `Kernel.inspect` on the data carries an overhead so
`Og.log/2` and `Og.log_r/2` should be probably be reserved for debugging code in `:dev`
environments.


## Configuration

    config :logger, :og,
      kernel_opts: [width: 70],
      apex_opts: [numbers: :false, color: :false],
      sanitize_by_default: :false,
      default_inspector: :kernel


## Configuration options

- `kernel_opts` - corresponds to elixir inspect opts for `IO.inspect/2`
and `Kernel.inspect/2`, refer to `https://hexdocs.pm/elixir/Inspect.Opts.html`


- `apex_opts` - corresponds to options for the `Apex.Format.format/2` function,
refer to `https://github.com/BjRo/apex/blob/master/lib/apex/format.ex`


- `sanitize_by_default` - defaults to `:false`, when set to `:true`, an attempt will
be made to apply the `SecureLogFormatter.sanitize/1` function on the data
before applying the inspection function. For this function to take any
effect, the settings for `SecureLogFormatter` must also be placed in
`config.exs`. See the following
[secure_log_formatter url](https://github.com/localvore-today/secure_log_formatter/blob/master/lib/secure_log_formatter.ex)
for more details.


- `default_inspector` - corresponds to the default inspector which will apply
to the data passed to the log function. This can be overriden in the options
of the log function. The options are `:kernel` or `:apex`, the default is `:kernel`.


Example configuration for secure_log_formatter, as referenced at
the following [secure_log_formatter url](https://github.com/localvore-today/secure_log_formatter/blob/master/lib/secure_log_formatter.ex).


    config :logger,
      secure_log_formatter:
        [
          # Map and Keyword List keys who's value should be hidden
          fields: ["password", "credit_card", ~r/.*_token/],

          # Patterns which if found, should be hidden
          patterns: [~r/4[0-9]{15}/] # Simple credit card example

          # defaults to "[REDACTED]"
          replacement: "[PRIVATE]"
        ]


### some examples


- Basic logging

```elixir
Og.log(:this_is_a_test)
```

- Logging at the `:warn` level

```elixir
Og.log(:this_is_a_test, level: :warn)
```

- Logging at the `:warn` level and with __ENV__ specified to get richer information

```elixir
Og.log(:this_is_a_test, level: :warn, env: __ENV__)
````

- Logging with the Apex inspector

```elixir
Og.log(:this_is_a_test, inspector: :apex)
```

- Logging and applying sanitization with the features of
[secure_log_formatter](https://github.com/localvore-today/secure_log_formatter)

```elixir
Og.log(%{credit_card: 4111111111111}, sanitize: :true)
```

- Logging inside a chain of piped functions

```elixir
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


### Dependencies

- [Apex library](https://hex.pm/packages/apex) --- [Björn Rochel](https://hex.pm/users/bjro)
    - Setting the `config.exs` opts or the log function opts to `inspector: :apex`
    will use the `Apex.Format.format/2` function from the apex library.


- [SecureLogFormatter library](https://hex.pm/packages/secure_log_formatter)  ---  [Sean Callan](https://hex.pm/users/doomspork)
    - Setting `config.exs` opts or the log function opts to `sanitize: :true`
    will use the `SecureLogFormatter.sanitize/1` function from the SecureLogFormatter library.


### Todo

- [ ] Investigate adding a custom formatting module as an optional additional means of logging.


### Licence

MIT
