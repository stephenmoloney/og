defmodule Og do
  @moduledoc ~S"""
  Some convenience utility functions on top of the elixir `Logger` module. Mostly useful for debugging purposes.

  ## Summary


  - `log/1`, `log/2`, `alog/1`, `alog/2`, `klog/1`, `klog/2`

  - Inspects the data before logging it. For example, this can be helpful for avoiding the `Protocol.UndefinedError`
  when logging tuples for example. There are two choices for formatting the data:

      1. `Kernel.inspect/2` (from erlang core)
      2. `Apex.Format.format/2` from [Apex](https://hex.pm/packages/apex) library for pretty printing

  - Configure the inspection function in the `config.exs` file by passing:

      config :logger, :og, default_inspector: Kernel.inspect/2

      or

      config :logger, :og, default_inspector: Apex.Format.format/2

  - *Optionally* pass the log_level `:debug`, `:info`, `:warn` or `:error` which will respect the
  logger `:compile_time_purge_level` configuration setting. Defaults to `:debug`.


  - `log_r/1`, `log_r/2`, `alog_r/1`, `alog_r/2`, `klog_r/1`, `klog_r/2`

  - Performs operations identical to `Og.log/4` but returns the data in it's original form.

  - Can be useful when one wants to log some intermediate data in the middle of a series of
  data transformations using the `|>` operator. see the example in `log_return/4`.


  ## Example configuration

  - Short example:

  ```
  use Mix.Config

  config :logger,
    backends: [:console],
    level: :debug,
    compile_time_purge_level: :debug,
    compile_time_application: :my_app,
    truncate: (4096 * 8),
    utc_log: :false

  config :logger, :console,
    level: :debug,
    format: "$time $metadata [$level] $message\n",
    metadata: []

  config :logger, :og,
    default_inspector: &Kernel.inspect/2
  ```

  - Long example:

  ```
  use Mix.Config
  limiter1 = "===================    [$level]    ========================"
  datetime = "|---$date $time"
  metadata = "|---$metadata"
  node = "|---$node"
  msg = "|---message:"
  limiter2 = "==================   [end $level]    ======================="

  config :logger,
    backends: [:console],
    level: :debug,
    compile_time_purge_level: :debug,
    compile_time_application: :my_app,
    truncate: (4096 * 8),
    utc_log: :false

  config :logger, :console,
    level: :debug,
    format: "#{limiter1}\n#{datetime}\n#{metadata}\n#{node}\n#{msg}\n\n$message\n\n#{limiter2}\n",
    metadata: [:module, :function, :line]

  config :logger, :og,
    default_inspector: &Kernel.inspect/2,
    kernel: [
      inspect_opts: [width: 70]
    ],
    apex: [
      format_opts: [numbers: :false, color: :false]
    ]
  ```

  """
 require Logger
 @default_inspector (Application.get_env(:logger, :og) || []) |> Keyword.get(:default_inspector, &Kernel.inspect/2)
 @kernel_opts (Application.get_env(:logger, :og) || []) |> Keyword.get(:kernel, [])
 @kernel_inspect_opts Keyword.get(@kernel_opts, :inspect_opts, [])
 @apex_opts (Application.get_env(:logger, :og) || []) |> Keyword.get(:apex, [])
 @apex_format_opts Keyword.get(@apex_opts, :format_opts, [color: :false, numbers: :false])
 @default_opts if @default_inspector == &Kernel.inspect/2, do: @kernel_inspect_opts, else: @apex_format_opts


  # Public

  @doc "Logs the data formatted with the `default_inspector` function and log_level `:debug`"
  @spec log(any) :: :ok
  def log(data), do: log(data, :debug)

  @doc "Logs the data formatted with the `default_inspector` function and log_level passed as the second argument"
  @spec log(any, atom) :: :ok
  def log(data, log_level) when is_atom(log_level) do
    data = @default_inspector.(data, @default_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: data], requires: [Logger])
    :ok
  end
  def log(data, %Macro.Env{} = env) do
    log(data, env, :debug)
  end

  @doc :false
  def log(data, %Macro.Env{} = env, log_level) do
    data = base_details(env) <> @default_inspector.(data, @default_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: data], requires: [Logger])
    :ok
  end

  @doc "Logs the data formatted with the `Kernel.inspect/2` function and log_level `:debug`"
  @spec klog(any) :: :ok
  def klog(data), do: klog(data, :debug)

  @doc "Logs the data formatted with the `Kernel.inspect/2` function and log_level passed as the second argument"
  @spec klog(any, atom) :: any
  def klog(data, log_level) when is_atom(log_level) do
    data = Kernel.inspect(data, @kernel_inspect_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: data], requires: [Logger])
    :ok
  end
  def klog(data, %Macro.Env{} = env) do
    klog(data, env, :debug)
  end

  @doc :false
  def klog(data, %Macro.Env{} = env, log_level) do
    data = base_details(env) <> Kernel.inspect(data, @kernel_inspect_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: data], requires: [Logger])
    :ok
  end

  @doc "Logs the data formatted with the `Apex.Format.format/2` function and log_level `:debug`"
  @spec alog(any) :: :ok
  def alog(data), do: alog(data, :debug)

  @doc "Logs the data formatted with the `Apex.Format.format/2` function and log_level passed as the second argument"
  @spec alog(any, atom) :: any
  def alog(data, log_level) when is_atom(log_level) do
    data = Apex.Format.format(data, @apex_format_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: data], requires: [Logger])
    :ok
  end
  def alog(data, %Macro.Env{} = env) do
    alog(data, env, :debug)
  end

  @doc :false
  def alog(data, %Macro.Env{} = env, log_level) do
    data = base_details(env) <> Apex.Format.format(data, @apex_format_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: data], requires: [Logger])
    :ok
  end


  @doc "Logs the data formatted with the `default_inspector` function and log_level `:debug`.
  Returns the original data"
  @spec log_r(any) :: any
  def log_r(data), do: log_r(data, :debug)

  @doc "Logs the data formatted with the `default_inspector` function and log_level passed as the second argument.
  Returns the original data"
  @spec log_r(any, atom) :: any
  def log_r(data, log_level) when is_atom(log_level) do
    log_data = @default_inspector.(data, @default_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: log_data], requires: [Logger])
    data
  end
  def log_r(data, %Macro.Env{} = env) do
    log_r(data, env, :debug)
  end

  @doc :false
  def log_r(data, %Macro.Env{} = env, log_level) do
    log_data = base_details(env) <> @default_inspector.(data, @default_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: log_data], requires: [Logger])
    data
  end

  @doc "Logs the data formatted with the `Kernel.inspect/2` function and log_level `:debug`"
  @spec klog_r(any) :: any
  def klog_r(data), do: klog_r(data, :debug)

  @doc "Logs the data formatted with the `Kernel.inspect/2` function and log_level passed as the second argument"
  @spec klog_r(any, atom) :: any
  def klog_r(data, log_level) when is_atom(log_level) do
    log_data = Kernel.inspect(data, @kernel_inspect_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: log_data], requires: [Logger])
    data
  end
  def klog_r(data, %Macro.Env{} = env) do
    klog_r(data, env, :debug)
  end

  @doc :false
  def klog_r(data, %Macro.Env{} = env, log_level) do
    log_data = base_details(env) <> Kernel.inspect(data, @kernel_inspect_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: log_data], requires: [Logger])
    data
  end

  @doc "Logs the data formatted with the `Apex.Format.format/2` function and log_level `:debug`"
  @spec alog_r(any) :: any
  def alog_r(data), do: alog_r(data, :debug)

  @doc "Logs the data formatted with the `Apex.Format.format/2` function and log_level passed as the second argument"
  @spec alog_r(any, atom) :: any
  def alog_r(data, log_level) when is_atom(log_level) do
    log_data = Apex.Format.format(data, @apex_format_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: log_data], requires: [Logger])
    data
  end
  def alog_r(data, %Macro.Env{} = env) do
    alog_r(data, env, :debug)
  end

  @doc :false
  def alog_r(data, %Macro.Env{} = env, log_level) do
    log_data = base_details(env) <> Apex.Format.format(data, @apex_format_opts)
    Code.eval_string("Logger.#{Atom.to_string(log_level)}(args)", [args: log_data], requires: [Logger])
    data
  end

  ## To be deprecated
  @doc :false
  def log_return(data), do: log_r(data, :debug)

  ## To be deprecated
  @doc :false
  def log_return(data, log_level) when is_atom(log_level), do: log_r(data, log_level)
  def log_return(data, env), do: log_r(data, env, :debug)

  ## To be deprecated
  @doc :false
  def log_return(data, env, log_level) when is_map(env), do: log_r(data, env, log_level)
  def log_return(data, log_level, _inspect_opts) do
    IO.puts("Please note that passing the inspect_opts to log_return has now been deprecated, use another function")
    log_r(data, log_level)
  end

  ## To be deprecated
  @doc :false
  def log_return(data, env, log_level, _inspect_opts) do
    IO.puts("Please note that passing the inspect_opts to log_return has now been deprecated, use another function")
    log_r(data, env, log_level)
  end


  # Private


  defp base_details(env) do
    put_into_string = fn(elem, name) ->
      case elem do
        :nil -> :nil
        _ -> "#{name}: #{elem}, "
      end
    end
    function =
    case env.function do
      :nil ->  :nil
      {function, arity} -> "#{function}/#{arity}"
    end
    application = Application.get_env(:logger, :compile_time_application) |> put_into_string.("application")
    module = put_into_string.(env.module, "module")
    function = put_into_string.(function, "function")
    line = put_into_string.(env.line, "line") |> String.trim_trailing(" ") |> String.trim_trailing(",")
    "#{application}#{module}#{function}#{line}:\n"
  end

end
