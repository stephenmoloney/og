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
      1. Avoiding the `Protocol.UndefinedError` when logging tuples for example.
      2. Not needing to require Logger


  - However, the functions `Og.log` and `Og.log_r` should be reserved for
  debugging code only in `:dev` environments and should not
   be used in production because:
      - Formatting the data carries an overhead.


  There are two choices of inspector functions for formatting the data:
      1. [inspector: :kernel] - `&Kernel.inspect/2` (from erlang core and the default)
      2. [inspector: :apex] - `&Apex.Format.format/2` from [Apex](https://hex.pm/packages/apex) library for pretty printing


  - Optionally, configure the inspection formatter options
   in the `config.exs` file by passing:

      config :logger, :og,
        kernel_opts: [width: 70],
        apex_opts: [numbers: :false, color: :false]

  ## Example configuration of the `Logger`

  - Short example:

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
 @kernel_opts Application.get_env(:logger, :og, [])
              |> Keyword.get(:kernel_opts, [])
 @apex_opts Application.get_env(:logger, :og, [])
            |> Keyword.get(:apex_opts, [color: :false, numbers: :false])


  # Public

  @doc """
  Formats the data using an inspector function, logs it and returns the
  atom `:ok`.

  ## Notes:

    - There is an overhead in converting the data to
      other formats such as a binary representation. Hence,
      `Og.log/2` and `Og.log_r/2` are preferred for
      development debugging purposes only.

  ## opts


      - ***level***: defaults to `:debug`.

          - Examples:

              Og.log(%{test: "test"}, [])

              Og.log(%{test: "test"}, [level: :info])


      - ***env***: defaults to `:nil`.

      Can be passed if details of the caller are desired in the output.
      Note: defaulting to `__CALLER__` special form
      is not desired since that would require converting this function to a
      macro reducing utility as a debugging tool.

          - Examples:

              Og.log(%{test: "test"}, [])

              Og.log(%{test: "test"}, [env: __ENV__])


      - ***inspector***: defaults to `:default_inspector` in the application config.exs and if
       not set, otherwise, defaults to `&Kernel.inspect/2`.

       The inspector function determines how the data will be transformed. Currently
       the options are `&Kernel.inspect/2` or `&Apex.Format.format/2`.

          - Examples:

              Og.log(%{test: "test"}, [])

              Og.log(%{test: "test"}, [inspector: Apex.Format.format/2])
  """
  @spec log(any, Keyword.t | Macro.Env.t) :: :ok
  def log(data, opts \\ []) do
    inspector = Keyword.get(opts, :inspector, :kernel)
    inspector_opts =
    case inspector do
      :kernel -> @kernel_opts
      :apex -> @apex_opts
      _ -> @kernel_opts
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


  @doc """
  Formats the data using an inspector function, logs it and returns the
  original data.

  ## Notes:

    - There is an overhead in converting the data to
      other formats such as a binary representation. Hence,
      `Og.log/2` and `Og.log_r/2` are preferred for
      development debugging purposes only.

  ## opts


      - ***level***: defaults to `:debug`.

          - Examples:

              Og.log(%{test: "test"}, [])

              Og.log(%{test: "test"}, [level: :info])


      - ***env***: defaults to `:nil`.

      Can be passed if details of the caller are desired in the output.
      Note: defaulting to `__CALLER__` special form
      is not desired since that would require converting this function to a
      macro reducing utility as a debugging tool.

          - Examples:

              Og.log(%{test: "test"}, [])

              Og.log(%{test: "test"}, [env: __ENV__])


      - ***inspector***: defaults to `:default_inspector` in the application config.exs and if
       not set, otherwise, defaults to `&Kernel.inspect/2`.

       The inspector function determines how the data will be transformed. Currently
       the options are `&Kernel.inspect/2` or `&Apex.Format.format/2`.

          - Examples:

              Og.log(%{test: "test"}, [])

              Og.log(%{test: "test"}, [inspector: Apex.Format.format/2])
  """
  @spec log_r(any, Keyword.t) :: any
  def log_r(data, opts \\ []) do
    log(data, opts)
    data
  end


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
