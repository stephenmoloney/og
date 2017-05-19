defmodule Og do
  @moduledoc ~S"""
  Óg is a small collection of debugging helper functions. Og is a debugging tool primarily
  intendend for development, the use of ordinary `Logger` is preferred for production.

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
  `config.exs`. See
  [secure_log_formatter](https://github.com/localvore-today/secure_log_formatter/blob/master/lib/secure_log_formatter.ex)
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
  """
  require Logger
  defp kernel_opts(), do: Application.get_env(:logger, :og, [])
                          |> Keyword.get(:kernel_opts, [])
  defp apex_opts(), do: Application.get_env(:logger, :og, [])
                        |> Keyword.get(:apex_opts, [color: :false, numbers: :false])
  defp default_inspector(), do: Application.get_env(:logger, :og, [])
                        |> Keyword.get(:default_inspector, :kernel)
  defp sanitize_by_default?(), do: Application.get_env(:logger, :og, [])
                        |> Keyword.get(:sanitize_by_default, :false)


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

  - ***level***: defaults to `:debug`.

  - ***env***: defaults to `:nil`.

  - ***inspector***: defaults to `:default_inspector` in the application config.exs and if not
  set falls back to `Kernel.inspect/2`.
  The inspector function determines what function transforms the data prior to logging.
  Currently the options are `:kernel` or `:apex` which use
  the functions `&Kernel.inspect/2` and `&Apex.Format.format/2` respectively.

  - ***sanitize***: defaults to `:sanitize_by_default` in the application config.exs and if not
  set falls back to `:false`.
  When set to `:true` the function `SecureLogFormatter.sanitize/1` will be applied to
  the data prior to logging the data. See
  [secure_log_formatter](https://github.com/localvore-today/secure_log_formatter/blob/master/lib/secure_log_formatter.ex)
  for more details.

  ## Examples:

      Og.log(%{test: "test"})

      Og.log(%{test: "test"}, level: :info)

      Og.log(%{test: "test"}, env: __ENV__)

      Og.log(%{test: "test"}, inspector: :apex)
  """
  @spec log(any, Keyword.t) :: :ok
  def log(data, opts \\ [])
  def log(data, opts) when is_list(opts) do
    inspector = Keyword.get(opts, :inspector, default_inspector())
    sanitize? = Keyword.get(opts, :sanitize, sanitize_by_default?())
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
    data =
    case sanitize? do
      :true -> SecureLogFormatter.sanitize(data)
      :false -> data
    end
    env = Keyword.get(opts, :env, :nil)
    level = Keyword.get(opts, :level, :debug)
    (base_details(env) <> inspector.(data, inspector_opts))
    |> log_data(level)
    :ok
  end

  @spec log(data :: any, env :: Macro.Env.t) :: :ok
  def log(data, env_or_level)
  @spec log(data :: any, level :: atom) :: :ok
  def log(data, :error), do: Og.log(data, level: :error)
  def log(data, :warn), do: Og.log(data, level: :warn)
  def log(data, :info), do: Og.log(data, level: :info)
  def log(data, :debug), do: Og.log(data, level: :debug)

  @spec log(data :: any, env :: Macro.Env.t, level :: atom) :: :ok
  def log(data, %Macro.Env{} = arg, :error), do: Og.log(data, env: arg, level: :error)
  def log(data, %Macro.Env{} = arg, :warn), do: Og.log(data, env: arg, level: :warn)
  def log(data, %Macro.Env{} = arg, :info), do: Og.log(data, env: arg, level: :info)
  def log(data, %Macro.Env{} = arg, :debug), do: Og.log(data, env: arg, level: :debug)
  @spec log(data :: any, level :: atom, env :: Macro.Env.t) :: :ok
  def log(data, :error, %Macro.Env{} = arg), do: Og.log(data, env: arg, level: :error)
  def log(data, :warn, %Macro.Env{} = arg), do: Og.log(data, env: arg, level: :warn)
  def log(data, :info, %Macro.Env{} = arg), do: Og.log(data, env: arg, level: :info)
  def log(data, :debug, %Macro.Env{} = arg), do: Og.log(data, env: arg, level: :debug)


  @doc """
  Formats the data using an inspector function, logs it and returns the
  original data.

  ## Notes:

  There is an overhead in converting the data to
  other formats such as a binary representation. Hence,
  `Og.log/2` and `Og.log_r/2` are preferred for
  development debugging purposes only.

  ## opts

  - ***level***: defaults to `:debug`.

  - ***env***: defaults to `:nil`.

  - ***inspector***: defaults to `:default_inspector` in the application config.exs.
  The inspector function determines what function transforms the data prior to logging.
  Currently the options are `:kernel` or `:apex` which use
  the functions `&Kernel.inspect/2` and `&Apex.Format.format/2` respectively.

  - ***sanitize***: defaults to `:sanitize_by_default` in the application config.exs.
  When set to `:true` the function `SecureLogFormatter.sanitize/1` will be applied to
  the data prior to logging the data. See
  [secure_log_formatter](https://github.com/localvore-today/secure_log_formatter/blob/master/lib/secure_log_formatter.ex)
  for more details.


  ## Examples:

      Og.log(%{test: "test"})

      Og.log(%{test: "test"}, level: :info)

      Og.log(%{test: "test"}, env: __ENV__)

      Og.log(%{test: "test"}, inspector: :apex)
  """
  @spec log_r(any, Keyword.t) :: any
  def log_r(data, opts \\ [])
  def log_r(data, opts) when is_list(opts) do
    log(data, opts)
    data
  end

  @spec log_r(data :: any, env :: Macro.Env.t) :: any
  def log_r(data, %Macro.Env{} = env), do: Og.log_r(data, env: env)
  @spec log_r(data :: any, level :: atom) :: any
  def log_r(data, :error), do: Og.log_r(data, level: :error)
  def log_r(data, :warn), do: Og.log_r(data, level: :error)
  def log_r(data, :info), do: Og.log_r(data, level: :info)
  def log_r(data, :debug), do: Og.log_r(data, level: :debug)

  @spec log_r(data :: any, env :: Macro.Env.t, level :: atom) :: any
  def log_r(data, %Macro.Env{} = arg, :error), do: Og.log_r(data, env: arg, level: :error)
  def log_r(data, %Macro.Env{} = arg, :warn), do: Og.log_r(data, env: arg, level: :warn)
  def log_r(data, %Macro.Env{} = arg, :info), do: Og.log_r(data, env: arg, level: :info)
  def log_r(data, %Macro.Env{} = arg, :debug), do: Og.log_r(data, env: arg, level: :debug)
  @spec log_r(data :: any, level :: atom, env :: Macro.Env.t) :: any
  def log_r(data, :error, %Macro.Env{} = arg), do: Og.log_r(data, env: arg, level: :error)
  def log_r(data, :warn, %Macro.Env{} = arg), do: Og.log_r(data, env: arg, level: :warn)
  def log_r(data, :info, %Macro.Env{} = arg), do: Og.log_r(data, env: arg, level: :info)
  def log_r(data, :debug, %Macro.Env{} = arg), do: Og.log_r(data, env: arg, level: :debug)


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
