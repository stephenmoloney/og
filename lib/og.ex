defmodule Og do
 @moduledoc ~S"""
 Some convenience utility functions on top of the elixir `Logger` module.

 ## Note:
    The following is the order of precedence for logging:

    `:error > :warn > :info > :debug`
 """
 require Logger


  @doc ~S"""
  Logs data after passing `data` first to the `Kernel.inspect/2`.

  data : data to be logged

  log_level: `:info` or `:debug` or `:warn` or `:error`

  inspect_opts: Keyword list of inspect options. see [here](http://elixir-lang.org/docs/stable/elixir/Kernel.html#inspect/2)

  ## Example

      Og.log(String.to_atom("test"))
  """
  @spec log(data :: any, log_level :: atom, inspect_opts :: list) :: atom
  def log(data, log_level \\ :debug, inspect_opts \\ []) do
    unless is_binary(data), do: data = Kernel.inspect(data)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: data], requires: [Logger])
    :ok
  end



  @doc """
  Logs `data` term by using the Kernel.inspect/2 and returns the original data type. Useful in a pipeline of functions.

  ## Example
       Og.log_return(String.to_atom("test"))

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
  @spec log_return(data :: any, log_level :: atom, inspect_opts :: list) :: any
  def log_return(data, log_level \\ :debug, inspect_opts \\ []) do
    log(data, log_level, inspect_opts)
    data
  end



  @doc ~S"""
  Logs contextual information of the environment of the caller.

  Logs
      module: #{module}, function: #{function}, line: #{line}

  ## Example

      defmodule Test do
        def env_test() do
          Og.context(__ENV__)
        end
      end

      Test.env_test()
  """
  @spec context(env :: Macro.Env.t, log_level :: atom, inspect_opts :: list) :: atom
  def context(env, log_level \\ :debug, inspect_opts \\ []) do
    base_details(env) |> log(log_level, inspect_opts)
  end



  @doc ~S"""
  Logs contextual information of the environment of the caller and the conn struct.

  Logs by default
      "module: #{module}, function: #{function}, line: #{line}, conn_details: { method: #{conn.method}, path: #{conn.request_path}" }"
  More conn struct fields can be logged by passing them in the conn_fields list.

  ## Example

      defmodule Test do
        use Plug.Test
        def test() do
          conn = Plug.Test.conn(:get, "/test", :nil)
          Og.conn_context(conn, __ENV__)
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
  @spec conn_context(conn :: Plug.Conn.t, env :: Macro.Env.t, log_level :: atom, conn_fields :: list, inspect_opts :: list) :: atom
  def conn_context(conn, env, log_level \\ :debug, conn_fields \\ [:method, :request_path], inspect_opts \\ []) do
    extra_args =
    Enum.reduce(conn_fields, "", fn(field, acc) ->
      if is_binary(Map.get(conn, field)) do
        acc <> Atom.to_string(field) <> ": " <> Map.get(conn, field) <> ", "
      else
        acc <> Atom.to_string(field) <> ": " <> Kernel.inspect(Map.get(conn, field)) <> ", "
      end
    end) |> String.rstrip(?\s) |> String.rstrip(?,)
    args = base_details(env) <> ", conn details: { " <> extra_args <> " }"
    log(args, log_level, inspect_opts)
  end


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
