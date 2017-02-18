defmodule Og do
  @moduledoc ~S"""
  Some convenience utility functions on top of the elixir `Logger` module. Mostly useful for debugging purposes.

  ## Summary


  `log/1`, `log/2`, `log/3`, `log/4`

  - Inspects the data before logging it. For example, this can be helpful for avoiding the `Protocol.UndefinedError`
  when logging tuples for example.
  - *Optionally* pass the  `__ENV__` environment variable to log the module, line and function, thereby,
  being able to identify exactly where the log was made.
  - *Optionally* pass the log_level `:debug`, `:info`, `:warn` or `:error` which will respect the
  logger `:compile_time_purge_level` configuration setting.
  - *Optionally* pass the inspect_opts argument to customise the inspect options in the `Kernel.inspect/2`
  function.


  `log_return/1`, `log_return/2`, `log_return/3`, `log_return/4`

  - Performs operations identical to `Og.log/4` but returns the data in it's original form.
  - The same options apply as for the `log` functions.
  - Can be useful when one wants to log some intermediate data in the middle of a series of
  data transformations using the `|>` operator. see the example in `log_return/4`.

  ## Inspect Opts

  - Defaults to the elixir default, `%Inspect.Opts{} |> Map.delete(:__struct__) |> Map.to_list()`
  - Can be modified in the `config.exs` file for the `Og` library and will be applied to all `log` functions.
  - Read more at [hex docs](https://hexdocs.pm/elixir/Inspect.Opts.html)
  - If the `inspect_opts` are changed in the `config.exs file, then the opts will be applied to all `log` and
  `log_return` function calls.
  - To override the inspect opts, pass the new settings to the `log` or `log_return` function, the application
  log settings in the `config.exs` file will then be completely ignored and the new `inspect_opts` will be merged
  with the elixir default `inspect_opts` settings.


  ## Example

  ```
  config :og, inspect_opts: [
    pretty: :true,
    width: 0,
    syntax_colors: [atom: :blue]
  ]
  ```

  """
 require Logger
 @default_conn_keys  [:method, :request_path]
 @elixir_default_inspect_opts %Inspect.Opts{} |> Map.delete(:__struct__) |> Map.to_list()
 @application_default_inspect_opts Application.get_env(:og, :inspect_opts)


  # Public

  @doc "log/1 -- see docs of `log/4`"
  @spec log(any) :: :ok
  def log(data), do: log(data, :debug, [])

  @doc "log/2 -- see docs of `log/4`"
  @spec log(any, Macro.Env.t |atom) :: :ok
  def log(data, log_level) when is_atom(log_level), do: log(data, log_level, [])
  def log(data, env), do: log(data, env, :debug, [])

  @doc "log/3 -- see docs of `log/4`"
  @spec log(any, Macro.Env.t | atom, atom | list) :: :ok
  def log(data, env, log_level) when is_map(env), do: log(data, env, log_level, [])
  def log(data, log_level, []) when is_atom(log_level) do
    inspect_opts = merge_inspect_opts(@elixir_default_inspect_opts, @application_default_inspect_opts)
    log(data, log_level, inspect_opts)
  end
  def log(data, log_level, inspect_opts) when is_atom(log_level) do
    merge_inspect_opts(@elixir_default_inspect_opts, inspect_opts)
    data = unless is_binary(data), do: Kernel.inspect(data, inspect_opts), else: data
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: data], requires: [Logger])
    :ok
  end

  @doc ~S"""
  Logs data after passing `data` first to the `Kernel.inspect/2` along with the environment of the caller.

  ## Arguments

      data: data to be logged
      env: environment of the function caller
      log_level: `:info` or `:debug` or `:warn` or `:error`
      inspect_opts: Keyword list of inspect options. see [here](http://elixir-lang.org/docs/stable/elixir/Kernel.html#inspect/2)

  ## Example - `log/1`

      Og.log(String.to_atom("test"))

  ## Example - `log/2`

      Og.log(String.to_atom("test"), __ENV__)

  ## Example - `log/2`

      Og.log(String.to_atom("test"), :error)

  ## Example - `log/3`

      Og.log(String.to_atom("test"), __ENV__, :warn)

  ## Example - `log/3`

      Og.log(String.to_atom("test"), :info, [pretty: :true])
      Og.log(String.to_atom("test"), :info, [pretty: :true, syntax_colors: [atom: :red]])

  ## Example - `log/4`

      list = Enum.reduce(1..10, [], fn(x, acc) -> [one: "1", two: "2"] ++ acc end)
      Og.log(list, __ENV__, :info, [pretty: :true, syntax_colors: [list: :green, atom: :blue], width: 0])
      Og.log(list, __ENV__, :info, [])

  """
  @spec log(any, Macro.Env.t, atom, Keyword.t) :: :ok
  def log(data, env, log_level, inspect_opts) do
    String.strip(base_details(env)) <> ", " <> Kernel.inspect(data, inspect_opts)
    |> log(log_level, inspect_opts)
  end


  @doc "log_return/1 -- see docs of `log_return/4`"
  @spec log_return(any) :: any
  def log_return(data), do: log_return(data, :debug, [])

  @doc "log_return/2 -- see docs of `log_return/4`"
  @spec log_return(any, Macro.Env.t | atom) :: any
  def log_return(data, log_level) when is_atom(log_level), do: log_return(data, log_level, [])
  def log_return(data, env), do: log_return(data, env, :debug, [])

  @doc "log_return/3 -- see docs of `log_return/4`"
  @spec log_return(any, Macro.Env.t | atom, atom | list) :: any
  def log_return(data, env, log_level) when is_map(env), do: log_return(data, env, log_level, [])
  def log_return(data, log_level, inspect_opts) do
    log(data, log_level, inspect_opts)
    data
  end


  @doc """
  Logs `data` term by using the Kernel.inspect/2 and returns the original data type. Useful in a pipeline of functions.

  ## Arguments

      data: data to be logged
      env: environment of the function caller
      log_level: `:info` or `:debug` or `:warn` or `:error`
      inspect_opts: Keyword list of inspect options. see [here](http://elixir-lang.org/docs/stable/elixir/Kernel.html#inspect/2)


  ## Example - `log_return/1`

      Og.log_return(String.to_atom("test"))

  ## Example - `log_return/1`

       %{first: "john", last: "doe"}
       |> Map.to_list()
       |> Enum.filter( &(&1 === {:first, "john"}))
       |> Og.log_return()
       |> List.last()
       |> Tuple.to_list()
       |> List.last()
       |> Og.log_return(__ENV__, :warn)
       |> String.upcase()

  ## Example - `log_return/2`

      Og.log_return(String.to_atom("test"), __ENV__)

  ## Example - `log_return/2`

      Og.log_return(String.to_atom("test"), :error)

  ## Example - `log_return/3`

      Og.log_return(String.to_atom("test"), __ENV__, :warn)

  ## Example - `log_return/3`

      Og.log_return(String.to_atom("test"), __ENV__, [pretty: :true])


  ## Example - `log_return/4`

    list = Enum.reduce(1..10, [], fn(x, acc) -> [one: "1", two: "2"] ++ acc end)
    Og.log_return(list, __ENV__, :info, [pretty: :true, syntax_colors: [list: :red, atom: :red], width: 0])

  """
  @spec log_return(any,  atom, Keyword.t) :: any
  def log_return(data, env, log_level, inspect_opts) do
    String.strip(base_details(env)) <> ", " <> Kernel.inspect(data, inspect_opts)
    |> log(log_level, inspect_opts)
    data
  end


  # Public docless functions

  @doc :false
  def context(env), do: context(env, :debug, [])

  @doc :false
  def context(env, log_level), do: context(env, log_level, [])

  @doc :false
  def context(env, log_level, inspect_opts) do
    base_details(env) |> log(log_level, inspect_opts)
  end

  @doc :false
  def conn_context(conn, env), do: conn_context(conn, env, :debug, @default_conn_keys, [])

  @doc :false
  def conn_context(conn, env, log_level), do: conn_context(conn, env, log_level, @default_conn_keys, [])

  @doc :false
  @spec conn_context(Plug.Conn.t, Macro.Env.t, atom, list) :: :ok
  def conn_context(conn, env, log_level, conn_fields), do: conn_context(conn, env, log_level, conn_fields, [])

  @doc :false
  def conn_context(conn, env, log_level, conn_fields, inspect_opts) do
    extra_args =
    Enum.reduce(conn_fields, "", fn(field, acc) ->
      if is_binary(Map.get(conn, field)) do
        acc <> Atom.to_string(field) <> ": " <> Map.get(conn, field) <> ", "
      else
        acc <> Atom.to_string(field) <> ": " <> Kernel.inspect(Map.get(conn, field), inspect_opts) <> ", "
      end
    end) |> String.rstrip(?\s) |> String.rstrip(?,)
    args = base_details(env) <> ", conn details: { " <> extra_args <> " }"
    log(args, log_level, inspect_opts)
  end


  # Private


  defp base_details(env) do
    {function, arity} =
    case env.function do
      :nil ->  {:nil, :nil}
      {function, arity} -> {function, arity}
    end
    module = env.module || :nil
    line = env.line || :nil
    if env.function == :nil do
      "module: #{module}, function: #{env.function}, line: #{line} "
    else
      "module: #{module}, function: #{function}/#{arity}, line: #{line} "
    end
  end

  # The keys in `opts2` will have precedence over duplicate keys in `opts1`
  @doc :false
  def merge_inspect_opts(opts1, opts2) do
    opts1 = Enum.into(opts1, %{})
    opts2 = Enum.into(opts2, %{})
    opts = Map.merge(opts1, opts2)
    Enum.into(opts, [])
  end


end
