defmodule Og do
 @moduledoc ~S"""
 Some convenience utility functions on top of the elixir `Logger` module.

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

 """
 require Logger
 @default_conn_keys  [:method, :request_path]


 # Public


  @doc "defaults to `log(data, :debug, [])`. see `log/3`"
  @spec log(any) :: :ok
  def log(data), do: log(data, :debug, [])

  @doc "defaults to `log(data, level, [])`. see `log/3`"
  @spec log(any, atom) :: :ok
  def log(data, log_level) when is_atom(log_level), do: log(data, log_level, [])

  @doc "defaults to `log(data, env, :debug, [])`. see `log/4`"
  @spec log(any, Macro.Env.t) :: :ok
  def log(data, env), do: log(data, env, :debug, [])

 @doc "defaults to `log(data, env, log_level, [])`. see `log/4`"
 @spec log(any, Macro.Env.t, atom) :: :ok
  def log(data, env, log_level) when is_map(env), do: log(data, env, log_level, [])

  @doc ~S"""
  Logs data after passing `data` first to the `Kernel.inspect/2`.

  ## Arguments

      data : data to be logged
      log_level: `:info` or `:debug` or `:warn` or `:error`
      inspect_opts: Keyword list of inspect options. see [here](http://elixir-lang.org/docs/stable/elixir/Kernel.html#inspect/2)

  ## Example

      Og.log(String.to_atom("test"))
  """
  @spec log(any, atom, Keyword.t) :: :ok
  def log(data, log_level, inspect_opts) when is_atom(log_level) do
    unless is_binary(data), do: data = Kernel.inspect(data, inspect_opts)
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

  ## Example

      Og.log(String.to_atom("test"), __ENV__)
      Og.log(String.to_atom("test"), __ENV__, :warn)
  """
  @spec log(any, Macro.Env.t, atom, Keyword.t) :: :ok
  def log(data, env, log_level, inspect_opts) do
    String.strip(base_details(env)) <> ", " <> Kernel.inspect(data, inspect_opts)
    |> log(log_level, inspect_opts)
  end


  @doc "defaults to `log_return(data, :debug, [])`. see `log_return/3`"
  @spec log_return(any) :: any
  def log_return(data), do: log_return(data, :debug, [])

  @doc "defaults to `log_return(data, level, [])`. see `log_return/3`"
  @spec log_return(any, atom) :: any
  def log_return(data, log_level) when is_atom(log_level), do: log_return(data, log_level, [])

  @doc "defaults to `log_return(data, env, :debug, [])`. see `log_return/4`"
  @spec log_return(any, Macro.Env.t) :: any
  def log_return(data, env), do: log_return(data, env, :debug, [])

  @doc "defaults to `log_return(data, env, log_level, [])`. see `log_return/4`"
  @spec log_return(any, Macro.Env.t, atom) :: any
  def log_return(data, env, log_level) when is_map(env), do: log_return(data, env, log_level, [])


  @doc """
  Logs `data` term by using the Kernel.inspect/2 and returns the original data type. Useful in a pipeline of functions.

  ## Arguments

    data : data to be logged
    log_level: `:info` or `:debug` or `:warn` or `:error`
    inspect_opts: Keyword list of inspect options. see [here](http://elixir-lang.org/docs/stable/elixir/Kernel.html#inspect/2)


  ## Example

       Og.log_return(String.to_atom("test"))
       Og.log_return(String.to_atom("test"), __ENV__, :warn)

  ## Example

       %{first: "john", last: "doe"}
       |> Map.to_list()
       |> Enum.filter( &(&1 === {:first, "john"}))
       |> Og.log_return()
       |> List.last()
       |> Tuple.to_list()
       |> List.last()
       |> Og.log_return()
       |> String.upcase()
  """
  @spec log_return(any, atom, Keyword.t) :: any
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

  ## Example

       Og.log_return(String.to_atom("test"))
       Og.log_return(String.to_atomncryptedubu2("test"), __ENV__)
       Og.log_return(String.to_atom("test"), __ENV__, :warn)

  ## Example

       %{first: "john", last: "doe"}
       |> Map.to_list()
       |> Enum.filter( &(&1 === {:first, "john"}))
       |> Og.log_return()
       |> List.last()
       |> Tuple.to_list()
       |> List.last()
       |> Og.log_return(__ENV__, :warn)
       |> String.upcase()
  """
  @spec log_return(any,  atom, Keyword.t) :: any
  def log_return(data, env, log_level, inspect_opts) do
    String.strip(base_details(env)) <> ", " <> Kernel.inspect(data, inspect_opts)
    |> log(log_level, inspect_opts)
    data
  end


  @doc "Logs contextual information of the environment of the caller. Defaults to `context(env, :debug, [])`. See `context/3`"
  @spec context(Macro.Env.t) :: :ok
  def context(env), do: context(env, :debug, [])


  @doc "Logs contextual information of the environment of the caller. Defaults to `context(env, :debug, [])`. See `context/3`"
  @spec context(Macro.Env.t, atom) :: :ok
  def context(env, log_level), do: context(env, log_level, [])


  @doc ~S"""
  Logs contextual information of the environment of the caller.

  ## Logs

      module: #{module}, function: #{function}, line: #{line}

  ## Example

      defmodule Test do
        def env_test() do
          Og.context()
        end
      end

      Test.env_test()
  """
  @spec context(Macro.Env.t, atom, Keyword.t) :: :ok
  def context(env, log_level, inspect_opts) do
    base_details(env) |> log(log_level, inspect_opts)
  end


  @doc ~s"""
  Logs contextual information of the environment of the caller and user selected details of the conn struct.
  Defaults to `conn_context(conn, env, :debug,  [:method, :request_path], [])`. See `conn_context/5`
  """
  @spec conn_context(Plug.Conn.t, Macro.Env.t) :: :ok
  def conn_context(conn, env), do: conn_context(conn, env, :debug, @default_conn_keys, [])


  @doc ~s"""
  Logs contextual information of the environment of the caller and user selected details of the conn struct.
  Defaults to `conn_context(conn, env, log_level, [:method, :request_path], [])`. See `conn_context/5`
  """
  @spec conn_context(Plug.Conn.t, Macro.Env.t, atom) :: :ok
  def conn_context(conn, env, log_level), do: conn_context(conn, env, log_level, @default_conn_keys, [])


  @doc ~s"""
  Logs contextual information of the environment of the caller and user selected details of the conn struct.
  Defaults to `conn_context(conn, env, log_level, conn_fields, [])`. See `conn_context/5`
  """
  @spec conn_context(Plug.Conn.t, Macro.Env.t, atom, list) :: :ok
  def conn_context(conn, env, log_level, conn_fields), do: conn_context(conn, env, log_level, conn_fields, [])


  @doc ~S"""
  Logs contextual information of the environment of the caller and user selected details of the conn struct.

  ## Logs by default

      module: #{module}, function: #{function}, line: #{line}, conn_details: { method: #{conn.method}, path: #{conn.request_path}" }

  More conn struct fields can be logged by passing them in the conn_fields list.

  ## Example

      defmodule Test do
        use Plug.Test
        def test() do
          conn = Plug.Test.conn(:get, "/test", :nil)
          Og.conn_context(conn)
        end
      end

      Test.test()

  ## Example

      defmodule Test do
        use Plug.Test
        def test() do
          conn = Plug.Test.conn(:get, "/test", :nil)
          Og.conn_context(conn, __ENV__, :warn, [:method, :req_headers, :peer])
        end
      end

      Test.test()
  """
  @spec conn_context(Plug.Conn.t, Macro.Env.t, atom, list, Keyword.t) :: :ok
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


end
