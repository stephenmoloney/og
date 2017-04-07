defmodule Og do
  @moduledoc ~S"""
  Óg is a small collection of debugging helper functions. Og is a debugging tool for development,
  the use of ordinary `Logger` is preferred for production.

  ## Summary

  - `log/2` - logs the data transformed by the inspector function
  and returns `:ok`
  - `log_r/2` - logs the data transformed by the inspector function
  and returns the original data.


  - Inspection of the data before logging it can be helpful in a debugging context for
      - Avoiding the `Protocol.UndefinedError` when logging tuples for example.
      - Not needing to require Logger


  - However, the functions `Og.log/2` and `Og.log_r/2` should be reserved for
  debugging code only in `:dev` environments and should not
   be used in production because:
      - Formatting the data carries an overhead.


  ## Example configuration of the `Logger`

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
        kernel_opts: [width: 70],
        apex_opts: [numbers: :false, color: :false]
  """
  require Logger
  defp kernel_opts(), do: Application.get_env(:logger, :og, [])
                          |> Keyword.get(:kernel_opts, [])
  defp apex_opts(), do: Application.get_env(:logger, :og, [])
                        |> Keyword.get(:apex_opts, [color: :false, numbers: :false])


  # Public

  @doc """
  Formats the data using an inspector function, logs it and returns the
  atom `:ok`.

  ## Notes:

  There is an overhead in converting the data to
  other formats such as a binary representation. Hence,
  `Og.log/2` and `Og.log_r/2` are preferred for
  development debugging purposes only.

  ## opts

  ***level***: defaults to `:debug`.

  ***env***: defaults to `:nil`.

  ***inspector***: defaults to `:default_inspector` in the application config.exs and if
  not set, otherwise, defaults to `:kernel`. The inspector function determines how the
  data will be transformed. Currently the options are `:kernel` or `:apex` which use
  the functions `&Kernel.inspect/2` and `&Apex.Format.format/2` respectively.


  ## Examples:

      Og.log(%{test: "test"})

      Og.log(%{test: "test"}, level: :info)

      Og.log(%{test: "test"}, env: __ENV__)

      Og.log(%{test: "test"}, inspector: :apex)
  """
  @spec log(any, Keyword.t) :: :ok
  def log(data, opts \\ []) do
    inspector = Keyword.get(opts, :inspector, :kernel)
    inspector_opts =
    case inspector do
      :kernel -> kernel_opts()
      :apex -> apex_opts()
      _ -> kernel_opts()
    end
    inspector =
    case inspector do
      :kernel -> &Kernel.inspect/2
      :apex -> &Apex.Format.format/2
      _ -> &Kernel.inspect/2
    end
    env = Keyword.get(opts, :env, :nil)
    level = Keyword.get(opts, :level, :debug)
    (base_details(env) <> inspector.(data, inspector_opts))
    |> log_data(level)
    :ok
  end

  @doc :false
  @spec log(data :: any, env :: Macro.Env.t) :: :ok
  def log(data, %Macro.Env{} = env), do: Og.log(data, env: env)

  @doc :false
  @spec log(data :: any, level :: atom) :: :ok
  def log(data, :error), do: Og.log(data, level: :error)
  def log(data, :warn), do: Og.log(data, level: :error)
  def log(data, :infor), do: Og.log(data, level: :info)
  def log(data, :debug), do: Og.log(data, level: :debug)

  @doc :false
  @spec log(data :: any, env :: Macro.Env.t, level :: atom) :: :ok
  def log(data, %Macro.Env{} = env, :error), do: Og.log(data, env: env, level: :error)
  def log(data, %Macro.Env{} = env, :warn), do: Og.log(data, env: env, level: :warn)
  def log(data, %Macro.Env{} = env, :info), do: Og.log(data, env: env, level: :info)
  def log(data, %Macro.Env{} = env, :debug), do: Og.log(data, env: env, level: :debug)

  @doc :false
  @spec log(data :: any, level :: atom, env :: Macro.Env.t) :: :ok
  def log(data, :error, %Macro.Env{} = env), do: Og.log(data, env: env, level: :error)
  def log(data, :warn, %Macro.Env{} = env), do: Og.log(data, env: env, level: :warn)
  def log(data, :info, %Macro.Env{} = env), do: Og.log(data, env: env, level: :info)
  def log(data, :debug, %Macro.Env{} = env), do: Og.log(data, env: env, level: :debug)


  @doc """
  Formats the data using an inspector function, logs it and returns the
  original data.

  ## Notes:

  There is an overhead in converting the data to
  other formats such as a binary representation. Hence,
  `Og.log/2` and `Og.log_r/2` are preferred for
  development debugging purposes only.

  ## opts

  ***level***: defaults to `:debug`.

  ***env***: defaults to `:nil`.

  ***inspector***: defaults to `:default_inspector` in the application config.exs and if
  not set, otherwise, defaults to `:kernel`. The inspector function determines how the
  data will be transformed. Currently the options are `:kernel` or `:apex` which use
  the functions `&Kernel.inspect/2` and `&Apex.Format.format/2` respectively.


  ## Examples:

      Og.log(%{test: "test"})

      Og.log(%{test: "test"}, level: :info)

      Og.log(%{test: "test"}, env: __ENV__)

      Og.log(%{test: "test"}, inspector: :apex)
  """
  @spec log_r(any, Keyword.t) :: any
  def log_r(data, opts \\ []) do
    log(data, opts)
    data
  end

  @doc :false
  @spec log_r(data :: any, env :: Macro.Env.t) :: any
  def log_r(data, %Macro.Env{} = env), do: Og.log_r(data, env: env)

  @doc :false
  @spec log_r(data :: any, level :: atom) :: any
  def log_r(data, :error), do: Og.log_r(data, level: :error)
  def log_r(data, :warn), do: Og.log_r(data, level: :error)
  def log_r(data, :infor), do: Og.log_r(data, level: :info)
  def log_r(data, :debug), do: Og.log_r(data, level: :debug)

  @doc :false
  @spec log_r(data :: any, env :: Macro.Env.t, level :: atom) :: any
  def log_r(data, %Macro.Env{} = env, :error), do: Og.log_r(data, env: env, level: :error)
  def log_r(data, %Macro.Env{} = env, :warn), do: Og.log_r(data, env: env, level: :warn)
  def log_r(data, %Macro.Env{} = env, :info), do: Og.log_r(data, env: env, level: :info)
  def log_r(data, %Macro.Env{} = env, :debug), do: Og.log_r(data, env: env, level: :debug)

  @doc :false
  @spec log_r(data :: any, level :: atom, env :: Macro.Env.t) :: any
  def log_r(data, :error, %Macro.Env{} = env), do: Og.log_r(data, env: env, level: :error)
  def log_r(data, :warn, %Macro.Env{} = env), do: Og.log_r(data, env: env, level: :warn)
  def log_r(data, :info, %Macro.Env{} = env), do: Og.log_r(data, env: env, level: :info)
  def log(data, :debug, %Macro.Env{} = env), do: Og.log_r(data, env: env, level: :debug)


  # Private


  defp base_details(:nil), do: ""
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


  defp log_data(formatted_data, level) do
    cond do
      level == :error -> Logger.error(formatted_data)
      level == :warn -> Logger.warn(formatted_data)
      level == :info -> Logger.info(formatted_data)
      level == :debug -> Logger.debug(formatted_data)
      :true -> raise("unexpected log level")
    end
  end

end
